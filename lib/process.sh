# Common shell functions

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/log.sh"
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/utils.sh"

_lsof() {
  local pid="$1"
  if ! lsof -p $pid 2>/dev/null; then
    /bin/ls -l /proc/$pid/fd 2>/dev/null
  fi
}

_pidof() {
  local cmd="$1"
  if ! pidof "$cmd" 2>/dev/null; then
     ps -eo pid,ucomm | awk -v comm="$cmd" '$2 == comm { print $1 }'
  fi
}

_pidofpattern() {
  local pattern="$1"
  pgrep -f "$pattern" 2>/dev/null
}

_userofpid() {
  local pid="$1"
  ps -o user= -p $pid
}

# don't use `kill -0` to check, as normal 
# user has no permission.
_is_pid_run() {
  local pid="$1"
  [ -z "$pid" ] && return 1
  if [ -d "/proc/$pid" ]; then
    return 0  # running
  else
    return 1  # not running
  fi
}

# get port from pid
_pidport() {
  local pid="$1"
  netstat -tnlp | \
    grep -P "\s+$pid/" | \
    head -n1 | \
    perl -ane '
      my ($port) = $F[3] =~ m/.+:(\d+)/;
      print $port
    '
}

# get pid from port
_portpid() {
  local port="$1"
  netstat -tnlp | \
    grep -P ":$port\s+" | \
    head -n1 | \
    perl -ane '
      my ($pid) = $F[-1] =~ m|(\d+?)/|;
      print $pid
    '
}

# get the cpu, memory ... of the pid process
get_pid_stat() {
  local pid="$1"
  if _is_pid_run "$pid"; then
    top -p $pid -bn2 -d 0.3 | \
      tail -n 1 | perl -ne '
        BEGIN {
          my %f=(
            B => 1, 
            K => 1_024, 
            M => 1_048_576, 
            G => 1_073_741_824, 
            T => 1_099_511_627_776
          );

          sub size_to_bytes {
            local $_ = shift;
            m/^((?:\d|\.)+)([kMGT])?/i; 
            return $1 * $f{uc($2 || "K")};
          }

          sub bytes_to_size {
            my $num = shift;
            if ($num >= $f{T}) {
              return sprintf("%.2fT", ($num / $f{T}));
            } 
            elsif ($num >= $f{G}) {
              return sprintf("%.2fG", ($num/ $f{G}));
            }
            elsif ($num >= $f{M}) {
              return sprintf("%.2fM", ($num / $f{M}));
            }
            elsif ($num >= $f{K}) {
              return sprintf("%.2fK", ($num/ $f{K}));
            }
            else {
              return $num . "B";
            }
          }

          sub time_to_minutes {
            local $_ = shift;
            # top time+ in format: 
            #   minutes:sendons.hundredths
            m/^(\d+)/;
            return ($1 || 0);
          }
        };

        chomp;
        s/^\s*|\s*$//g;
        my @list = split(/\s+/, $_);

        my @fields = qw(
          pid user priority nice virt res
          share state cpu mem time cmd
        );
        foreach my $k (@fields) {
          if (grep /$k/, qw(virt res share)) {
            $stats{$k} = bytes_to_size(size_to_bytes($list[$i]));
          }
          elsif ($k eq "time") {
            $stats{$k} = time_to_minutes($list[$i]);
          }
          elsif (grep /$k/, qw(cpu mem)) {
            $stats{$k} = $list[$i] . "%";
          }
          else {
            $stats{$k} = $list[$i];
          }
          $i++;
        }

        END {
          # return bash associative array format
          my $res = "(";
          for my $k (qw(pid user virt res share cpu mem time cmd)) {
            $res .= "[$k]=" . chr(34) . "$stats{$k}" . chr(34) . " ";
          }
          $res .= ")";
          print "$res\n";
        };
      '
  fi
}

# check host tcp port whether is open or not
is_host_port_open() {
  local ip="$1"
  local port="$2"

  NC_CMD=$(_which nc)
  if [ -x "$NC_CMD" ]; then
    if nc -z -v -w 3 $ip $port >/dev/null 2>&1; then
      return 0
    fi
  else
    # based on Perl IO::Socket::INET
    echo "$ip $port" | perl -MIO::Socket::INET -ne '
      chomp;
      my $fail = 0;
      my ($host, $port) = split(/\s+/, $_);
      my $socket = IO::Socket::INET->new(
        PeerAddr => $host,
        PeerPort => $port,
        Proto    => tcp,
        Timeout  => 3,
      ) || $fail++;

      if ($fail > 0) {
        print "$host:$port is closed\n";
        exit $fail;
      }
      print "$host:$port is open.\n";
      exit 0;
    '
  fi
}


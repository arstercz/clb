### workinit

The `workinit` library invoke by other library, it'll initinal global variables and create needed directories:

| variables | default value |
| :-: | :-: |
| WT_WORK_BASE | /tmp/clb-work |
| WT_WORK_DATA | ${WT_WORK_BASE}/data |
| WT_WORK_TEMP | ${WT_WORK_BASE}/temp |
| WT_WORK_CONF | ${WT_WORK_BASE}/conf |
| WT_WORK_LOGS | ${WT_WORK_BASE}/logs |

> sysadmin can change the variables value based on your self-requirement.

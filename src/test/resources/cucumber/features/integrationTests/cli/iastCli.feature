@IastFeature @IntegrationTest
Feature: Check integration with iast - stop scan and create jira issue by CLI/Jenikns
And command line example: ”java -jar cx-flow-1.6.21.jar --spring.config.location=application.yml --iast --bug-tracker="jira" --assignee="email@mail.com" --scan-tag="cx-scan-tag-1" --jira.url=https://xxxx.atlassian.net --jira.username=email@mail.com --jira.token=token --jira.project=BCB --iast.url="http://localhost" --iast.manager-port=8380 --iast.username="username" --iast.password="password" --iast.update-token-seconds=150 --jira.issue-type="Task"”


  Scenario Outline: test cli runner
    Given mock services "<scanTag>" "<filter-severity>" "<thresholds severity>"
    Given mock CLI runner "<scanTag>" "<bug tracker>"
    When running cli "<exit code>" "<scanTag>"
    Then check how many create issue "<create issue>" "<bug tracker>"

    Examples:
      | scanTag    | bug tracker | filter-severity      | thresholds severity              | exit code | create issue |
      | cx-scan-1  | jira        | HIGH,MEDIUM,LOW,INFO | HIGH=-1,MEDIUM=-1,LOW=-1,INFO=-1 | 0         | 2            |
      | cx-scan-2  | jira        | HIGH,MEDIUM,LOW,INFO | HIGH=-1,MEDIUM=-1,LOW=-1,INFO=-1 | 0         | 2            |
      | cx-scan-3  | jira        | HIGH,MEDIUM          | HIGH=-1,MEDIUM=-1,LOW=-1,INFO=-1 | 0         | 1            |
      | cx-scan-4  | jira        | HIGH                 | HIGH=-1,MEDIUM=-1,LOW=-1,INFO=-1 | 0         | 0            |
      | cx-scan-5  | jira        | HIGH,MEDIUM,LOW,INFO | HIGH=-1,MEDIUM=1,LOW=-1,INFO=-1  | 10        | 2            |
      | cx-scan-6  | jira        | HIGH,LOW,INFO        | HIGH=-1,MEDIUM=1,LOW=-1,INFO=-1  | 10        | 1            |
      | cx-scan-7  | jira        | HIGH,MEDIUM,LOW,INFO | HIGH=-1,MEDIUM=1,LOW=1,INFO=-1   | 10        | 2            |
      | cx-scan-8  | jira        | HIGH,MEDIUM,LOW,INFO | HIGH=-1,INFO=-1                  | 0         | 2            |

      | cx-scan-9  | githubissue | HIGH,MEDIUM,LOW,INFO | HIGH=-1,MEDIUM=-1,LOW=-1,INFO=-1 | 0         | 2            |
      | cx-scan-10 | githubissue | HIGH,MEDIUM,LOW,INFO | HIGH=-1,MEDIUM=-1,LOW=-1,INFO=-1 | 0         | 2            |
      | cx-scan-11 | githubissue | HIGH,MEDIUM          | HIGH=-1,MEDIUM=-1,LOW=-1,INFO=-1 | 0         | 1            |
      | cx-scan-12 | githubissue | HIGH                 | HIGH=-1,MEDIUM=-1,LOW=-1,INFO=-1 | 0         | 0            |
      | cx-scan-13 | githubissue | HIGH,MEDIUM,LOW,INFO | HIGH=-1,MEDIUM=1,LOW=-1,INFO=-1  | 10        | 2            |
      | cx-scan-14 | githubissue | HIGH,LOW,INFO        | HIGH=-1,MEDIUM=1,LOW=-1,INFO=-1  | 10        | 1            |
      | cx-scan-15 | githubissue | HIGH,MEDIUM,LOW,INFO | HIGH=-1,MEDIUM=1,LOW=1,INFO=-1   | 10        | 2            |
      | cx-scan-16 | githubissue | HIGH,MEDIUM,LOW,INFO | HIGH=-1,INFO=-1                  | 0         | 2            |


      | cx-scan-17 | gitlabissue | HIGH,MEDIUM,LOW,INFO | HIGH=-1,MEDIUM=-1,LOW=-1,INFO=-1 | 0         | 2            |
      | cx-scan-18 | gitlabissue | HIGH,MEDIUM,LOW,INFO | HIGH=-1,MEDIUM=-1,LOW=-1,INFO=-1 | 0         | 2            |
      | cx-scan-19 | gitlabissue | HIGH,MEDIUM          | HIGH=-1,MEDIUM=-1,LOW=-1,INFO=-1 | 0         | 1            |
      | cx-scan-20 | gitlabissue | HIGH                 | HIGH=-1,MEDIUM=-1,LOW=-1,INFO=-1 | 0         | 0            |
      | cx-scan-21 | gitlabissue | HIGH,MEDIUM,LOW,INFO | HIGH=-1,MEDIUM=1,LOW=-1,INFO=-1  | 10        | 2            |
      | cx-scan-22 | gitlabissue | HIGH,LOW,INFO        | HIGH=-1,MEDIUM=1,LOW=-1,INFO=-1  | 10        | 1            |
      | cx-scan-22 | gitlabissue | HIGH,MEDIUM,LOW,INFO | HIGH=-1,MEDIUM=1,LOW=1,INFO=-1   | 10        | 2            |
      | cx-scan-23 | gitlabissue | HIGH,MEDIUM,LOW,INFO | HIGH=-1,INFO=-1                  | 0         | 2            |

      | cx-scan-1  | azure       | HIGH,MEDIUM,LOW,INFO | HIGH=-1,MEDIUM=-1,LOW=-1,INFO=-1 | 0         | 2            |
      | cx-scan-2  | azure       | HIGH,MEDIUM,LOW,INFO | HIGH=-1,MEDIUM=-1,LOW=-1,INFO=-1 | 0         | 2            |
      | cx-scan-2  | azure       | HIGH,MEDIUM          | HIGH=-1,MEDIUM=-1,LOW=-1,INFO=-1 | 0         | 1            |
      | cx-scan-2  | azure       | HIGH                 | HIGH=-1,MEDIUM=-1,LOW=-1,INFO=-1 | 0         | 0            |
      # the following case: when at least one MEDIUM issue is found, the execution should be ended with error
      # (exit code = 10). All issues should be created (in this case two issues).
      | cx-scan-2  | azure       | HIGH,MEDIUM,LOW,INFO | HIGH=-1,MEDIUM=1,LOW=-1,INFO=-1  | 10        | 2            |
      # this next one fails as it as expected (exit code = 10) and just one issue is created, because the MEDIUM
      # vulnerability was found and, since that a MEDIUM is not eligible to create an issue (it is not between
      # filter-severity values), the execution is finished in error because of the thresholdsSeverity validation
      # (MEDIUM is defined as 1 on thresholds severity values).
      ### summing up: MEDIUM vulnerabilities does not create an issue, but when it is found the process FAIL (exit code = 10) ###
      | cx-scan-2  | azure       | HIGH,LOW,INFO        | HIGH=-1,MEDIUM=1,LOW=-1,INFO=-1  | 10        | 1            |
      | cx-scan-2  | azure       | HIGH,MEDIUM,LOW,INFO | HIGH=-1,MEDIUM=1,LOW=1,INFO=-1   | 10        | 2            |
      | cx-scan-2  | azure       | HIGH,MEDIUM,LOW,INFO | HIGH=-1,INFO=-1                  | 0         | 2            |
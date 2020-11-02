scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

command! -nargs=1 RMGetRedmineIssueDescription call tanikawa#redmine#GetRedmineIssueDescription(<f-args>)
command! -nargs=1 RMGetRedmineIssueURLandTitle call tanikawa#redmine#GetRedmineIssueURLandTitle(<f-args>)
command! -nargs=+ RMMkRedmineDiffCommit call tanikawa#redmine#MakeRedmineDiffCommit(<f-args>)
command! -nargs=+ -complete=custom,tanikawa#redmine#GetRedmineGitBranch RMMkRedmineDiffBranch call tanikawa#redmine#MakeRedmineDiffBranch(<f-args>, 0)
command! -nargs=+ -complete=custom,tanikawa#redmine#GetRedmineGitBranch RMMkRedmineDiffMergeBranch call tanikawa#redmine#MakeRedmineDiffBranch(<f-args>, 1)

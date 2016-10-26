#!/bin/bash
#
# This script resolves conflicts that can't be solved 'naturally', i.e. by talking to each other.
# Usually a conflict can be resolved by a rebase but in one particular case it won't work:
#
#        f-----g-----h         -> dev1
#       /
# a----b----c---d------e       -> master
#                \
#                 x-----y----z -> dev2
#
#
#
# Here if dev2 tries to rebase on dev1's branch it will look like this:
#
#        f-----g-----h                                       -> dev1
#       /
# a----b----c---d------e                                     -> master
#       \
#        f-----g-----h----c'---d'------e'----x'-----y'----z' -> dev2
#
#
#
# But actually we'd like to do something like:
#
#                      x'-----y'----z' -> dev2
#                     /
#        f-----g-----h                 -> dev1
#       /
# a----b----c---d------e               -> master
#
#

# Fetch all changes
git fetch

# Get the commits done on your branch since you left your main branch (x, y and z)
commits=""
while read line
do
      commit=`echo $line | awk '{print $1;}'`
      commits=$commit" "$commits
done < <(git log $2..HEAD --oneline)

echo "All following commits will be added: "$commits

# Get the name of your current branch
oldBranch=`git rev-parse --abbrev-ref HEAD`
newBranch=$oldBranch"-topped"

# Create a new branch from the one you depend (it sould be the only argument passed to this script)
git checkout $1
git checkout -b $newBranch

# Start cherry picking your commits
git cherry-pick $commits

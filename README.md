# Solving git conflicts

This script is useful for solving git conflicts when you are working with multiple branches - such as one stable release and one for validation.

Let's say our git workflow has two main branches:

- develop, which is the latest stable version
- staging, which contains the development that need to be validated


```
     ---------------          -> staging
    /
   /    f-----g-----h         -> dev1
  /    /
 a----b----c---d------e       -> develop
                \
                 x-----y----z -> dev2

```

For our example, dev1 merges into staging:


```
     -----------------m       -> staging
    /                /
   /    f-----g-----h         -> dev1
  /    /
 a----b----c---d------e       -> develop
                \
                 x-----y----z -> dev2

```

Now dev2 wants to merge into staging but has conflicts!
Here if dev2 tries to rebase on dev1's branch here what's going to happen:

- git will look for the latest common commit (that's b)
- then it will create a new branch starting at the end of dev1's branch (i.e. commit h)
- it will apply all commits that are on dev2's branch but not on dev1's (i.e. c, d, e, x, y, z)

```

        f-----g-----h                                       -> dev1
       /
 a----b----c---d------e                                     -> develop
       \
        f-----g-----h----c'---d'------e'----x'-----y'----z' -> dev2
```

And this will create trouble when dev2 will want to merge back in develop ad his branch won't have the same commits anymore!

The solution is to start from dev1's branch and cherry-pick the commits on dev2's branch from develop (x, y and z).

Like this:

```

                      x'-----y'----z' -> dev2-topped
                     /
        f-----g-----h                 -> dev1
       /
 a----b----c---d------e               -> develop
                \
                 x-----y----z         -> dev2

```

Then dev2-topped branch is the one to use as it can be merged in staging, and into develop once dev1 is merged :)


We've written a script that does that:

To use it edit your `~/.gitconfig` to add in the alias section (don't forget the exclamation mark `!`):

```
top = !/path/to/git-top.sh $1 your-main-branch-name
```

Then, while on the branch you worked on and with a clean working directory (no committed or changed file) run:

```
git top the-branch-you-want-to-go-from

```

The scripts ends with a cherry-pick, so if you have some conflicts solve them and then go on with `git cherry-pick --continue`.

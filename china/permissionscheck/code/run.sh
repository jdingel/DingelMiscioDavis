#!/bin/bash
echo "The following directories are owned by dclarke1"
find ../../ -group dclarke1 -type d
echo "Changing group ownership to pi-jdingel"
find ../../ -group dclarke1 -type d | xargs chgrp pi-jdingel
echo "The following directories are owned by jdingel"
find ../../../ -group jdingel -type d
echo "Changing group ownership to pi-jdingel"
find ../../../ -group jdingel -type d | xargs chgrp pi-jdingel


echo "The following files are owned by dclarke1"
find ../../ -group dclarke1
echo "Changing group ownership to pi-jdingel"
find ../../ -group dclarke1 | xargs chgrp pi-jdingel
echo "The following files are owned by jdingel"
find ../../ -group jdingel
echo "Changing group ownership to pi-jdingel"
find ../../ -group jdingel  | xargs chgrp pi-jdingel

echo "Group members do not have write permissions on the following directories"
ls -ld ../../*/*/ | grep -v drw..w
echo "An attempt to automate changes of permissions"
ls -ld ../../*/*/ | grep -v drw..w | awk '{print $9}' | xargs chmod 770

echo "Group members do not have write permissions on following do files:"
find ../../*/code/*.do  -type f \! -perm 660
echo "An attempt to automate changes of permissions"
find ../../*/code/*.do  -type f \! -perm 660  | xargs chmod 660

echo "Group members do not have write permissions on following shell scripts:"
find ../../*/code/*.sh  -type f \! -perm 660
echo "An attempt to automate changes of permissions"
find ../../*/code/*.sh  -type f \! -perm 660  | xargs chmod 660


echo "The following directories don't have sticky bits set for group members"
ls -ld ../../*/*/ | grep -v dr....s
echo "An attempt to change sticky bit"  #Jonathan doesn't have permission so he cannot check whether this command will work
ls -ld ../../*/*/ | grep -v dr....s | awk {'print $9'} | xargs chmod g+s

echo "The contents of initialdata/input should be read-only. The following files are not read-only:"
find ../../initialdata/input -type f ! -perm 440
echo "An attempt to change permissions of files within initialdata/input"
find ../../initialdata/input -type f ! -perm 440 | xargs chmod 440

Please go to your hypervisor Node and execute the scripts in their numbered order e.g 01- ... 02...
At the end there is a Directory called: Service Scripts/hypervisor.hX.rhaw.io in our git repository.
Copy these two files to: /usr/local/bin or /usr/local/sbin and make them executable: chmod a+x *.sh
These two scripts are helper Scripts for the Instructor to create a complete openshift Cluster (boostrap, master and worker nodes including disc)
and destroy the complete cluster when something went wrong with the installation.
The Scripts 04 and 05 are like or and 06 and 07 as well ... you need to choose between them.
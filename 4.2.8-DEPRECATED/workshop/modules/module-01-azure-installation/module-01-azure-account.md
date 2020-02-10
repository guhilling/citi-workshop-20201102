red Hat released Red Hat OpenShift [Container](http://www.reloga.de/container-mieten/bestellung/ "Container") Platform 4.1 (OCP4) earlier this year, introducing installer provisioned infrastructure and user provisioned infrastructure approaches on Amazon Web Services (AWS). The Installer provisioned infrastructure method is quick and only requires you to have AWS credentials, access to Red Hat telemetry and domain name. Red Hat also released a user provisioned approach where OCP4 can be deployed by leveraging CloudFormation, templates and using the same installer to generate ignition configuration files.  
Since Microsoft Azure is getting more and more business attention, natural question would be: when is OCP4 going to be released on Azure Cloud? At the time of the writing OCP4 on Azure using installer is in developer preview.   
One of the main challenges with running OCP4 on Azure with the installer provisioned infrastructure method is setting upcustom Ingress infrastructure (e.g. custom Network Security Groups or custom Load Balancer for routers), because the Cluster Ingress Operator creates a Public facing Azure Load Balancer to serve routers by default, and once the cluster is deployed, the Ingress Controller type cannot be changed.  
If it is deleted, or the OpenShift router Service type is changed, the Cluster Ingress Operator will reconcile and recreate the default controller object.  
Trying to alter Network Security Groups by whitelisting allowed IP ranges will cause Kubernetes to reconcile the configuration to it’s desired state.  
One of the ways is to deploy OCP4 on Azure Cloud by creating the objects manually with the user provisioned infrastructure approach, and then recreating the default ingress controller object just after control plane is deployed.  
Openshift [Container](http://www.reloga.de/container-mieten/bestellung/ "Container") Platform 4.1 components  
Our cluster consists of 3 master and 2 compute nodes. Master nodes are fronted with 2 Load Balancers, 1 Public facing for external API calls, and 1 Private for internal cluster communication. Compute nodes are using the same Public facing Load Balancer as the masters, but if needed they can each have their own Load Balancer.

Figure 1. OCP 4.1 design diagram with user provisioned infrastructure on Azure Cloud  
Instances sizes  
The OpenShift [Container](http://www.reloga.de/container-mieten/bestellung/ "Container") Platform 4.1 environment has some minimum hardware requirements.

Instance type  
Bootstrap  
Control plane  
Compute nodes

D2s_v3  
–  
–  
X

D4s_v3  
X  
X  
X

Above VM sizes might change once Openshift [Container](http://www.reloga.de/container-mieten/bestellung/ "Container") Platform 4.1 is officially released for Azure.  
Azure Cloud preparation for OCP 4.1 installation  
The preparation steps here are the same as for Installer Provisioned Infrastructure. You need to complete these steps:

DNS Zone.  
Credentials.  
Cluster Installation (Follow the guide until cluster deployment section).

NOTE: The free Trial account is not enough and Pay As You Go is recommended with increased quota for vCPU  
   
User Provisioned Infrastructure based OCP 4.1 installation  
When using this method, you can:

Specify the number of masters and workers you want to provision  
Change Network Security Group rules in order to lock down the ingress access to the cluster   
Change Infrastructure component names  
Add tags

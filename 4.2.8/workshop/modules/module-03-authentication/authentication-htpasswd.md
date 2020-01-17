# Chapter 2 - Authentication Providers

One important step after installing an Openshift 4 Cluster is to setup Authentication Providers. In this Workshop we will use htpasswd as an authentication provider.

## htpasswd Authentication Provider

After the initial Installation we can just login using the kuebadmin credentials created during the installation for getting access to our Openshift Cluster over CLI or Web Console.

Now we will create an htpasswd Provider to give more users access to Openshift.

If you want to use other authentication providers, please use the documentation:

[https://docs.openshift.com/container-platform/4.2/authentication/understanding-identity-provider.html](https://docs.openshift.com/container-platform/4.2/authentication/understanding-identity-provider.html)

First we need to create our htpasswd file on our services machine:

```
htpasswd -c -B -b /root/users.htpasswd <user_name> <password>
```

If we want to add more users we just need to update the file:

```
htpasswd -b /root/users.htpasswd <user_name> <password>
```

To use the HTPasswd identity provider, you must define a secret that contains the HTPasswd user file.

```
oc create secret generic htpass-secret --from-file=htpasswd=/root/users.htpasswd -n openshift-config
```

> The secret key containing the users file must be named `htpasswd`. The above command includes this name.
> 
> The secret key is within the "from-file" parameter. The "from-file" parameter basically is in the format `--from-file=_key_=_value_`. The example creates a secret called (i.e., having the name) "htpass-secret". That secret has a key "htpasswd" and the value of this key is imported from file '/root/users.htpasswd'.

Now we need to create a Custom Resource (CR) with the parameters and acceptable values for an HTPasswd identity provider. The Example below shows the Example Values:

```
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: lab_example_com_htpasswd_provider
    mappingMethod: claim 
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpass-secret
```

We need to create an YAML File with the content above. 

```
vim /root/htpasswd_cr.yaml
```

Then we need to apply these CR to our OCP4 Cluster:

```
oc apply -f /root/htpasswd_cr.yaml
```

**NOTE:** it is recommended to set one of the users created as _cluster_ admin using the command `oc policy add-role-to-user cluster-admin <admin-user-name>`.

## Testing the htpasswd Authentication Provider

We are now able to login with htpasswd over CLI and Web Console

### Logging in using Web Console

Next, let's login to the web-console and ensure that it's working as expected.

- navigate to the console URL:  https://console-openshift-console.apps.ocp4.lab.example.com
- Click `Advanced` and Click `proceed...` link on the browser, you should be
  presented with the page to select the authentication providers.
- The WebConsole will now show two login links:
    - 'kube:admin'
    - 'lab_example_com_htpasswd_provider' (this is the name of the htpasswd identity provider as defined above in the 'htpasswd_cr.yaml' file)
- Click on the htpasswd provider link
- Proceed to login with one of the username and password that you created and you should hit the OpenShift console home page.

**NOTE:** If you login as regular user, you will not see any project when logging in for the first time.

### Logging in using CLI and a new shell

Open a new shell on the services machine and
In this step ***do not*** reuse your existing shell which has the `KUBECONFIG` variable set for using the 'system:admin' user.

```
oc login -u <username> -p <password>  https://api.ocp4.lab.example.com:6443
```

You should be able to successfully login using the created user.
The result should be:

```
    oc login -u <username> -p <password> https://api.ocp4.lab.example.com:6443 --certificate-authority=ingress-ca.crt
Login successful.

You don't have any projects. You can try to create a new project, by running

    oc new-project <projectname>
```


### Logging in using CLI on a shell replacing system:admin login context 

> This is optional and documented for informational purposes only
> 
> We do not recommend replacing a context of the 'system:admin' user.

In case you use a shell having the `KUBECONFIG` variable set and where you currently have 'system:admin' as the user for ```oc whoami``` being set as user context, if you execute:

```
oc login -u <username> -p <password>  https://api.ocp4.lab.example.com:6443
```

this will cause an error like this:

```
error: x509: certificate signed by unknown authority
```

This error is known and there is a solution for this: [https://access.redhat.com/solutions/4505101](https://access.redhat.com/solutions/4505101)

To solve it we need to list all our oauth-openshift-pods

```
oc get pods -n openshift-authentication
```

The output should be something like this:

```
NAME                               READY   STATUS    RESTARTS   AGE
oauth-openshift-5bffc98df5-c7jzh   1/1     Running   0          34m
oauth-openshift-5bffc98df5-z7d8n   1/1     Running   0          34m
```

Now we select the first pod in our list and execute the following command:

```
oc rsh -n openshift-authentication <oauth-openshift-pod> cat /run/secrets/kubernetes.io/serviceaccount/ca.crt > ingress-ca.crt
```

Now execute the login command adding the `--certificate-authority` option:

```
oc login -u <username> -p <password> https://api.ocp4.lab.example.com:6443 --certificate-authority=ingress-ca.crt
```

Note that we now have modified/extended the `$KUBECONFIG` file by the additional login context. The examples below use 'the-example-user' as '<username>'.

```
oc config current-context
/api-ocp4-lab-example-com:6443/the-example-user
```

You can use `oc config get-contexts` to list all available contexts.

You can switch contexts and thus the logged-on user as follows:

```
# oc whoami
the-example-user

# oc config use-context admin
Switched to context "admin".

# oc whoami
system:admin

# oc config use-context /api-ocp4-lab-example-com:6443/the-example-user
Switched to context "/api-ocp4-lab-example-com:6443/the-example-user".

# oc whoami
the-example-user

```

## Example: ldap Authentication Provider

<TODO>

> Details can be found in the [product documentation](https://docs.openshift.com/container-platform/4.2/authentication/identity_providers/configuring-ldap-identity-provider.html).



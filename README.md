# IDwalll desafios-devops

Este desafio foi feito com `Vagrantfile` e associação de scripts de `Ansible`
para ao provisionamento de um cluster Kubernetes de 1 nó usando `VirtualBox` e `Ubuntu
16.04`.
O `Vagrant` foi utilizado para simular o servidor destino que irá receber o deploy automatizado através do `Ansible`.
Portanto não está limitado a rodar somente em Vagrant.
Mais a frente darei dicas de como rodar em qualquer servidor. 


### Pré Requisitos
Para executar o projeto você precisa ter instalado:
- `Vagrant`, versão 2.1.1 . Versões anteriores do vagrant podem não funcionar com
a imagem do vagrant para Ubuntu 16.04 e configurações de rede.
- `VirtualBox`, testado com a versão Version 5.1.34_Ubuntu r121010
- Acesso a Internet.
- A máquina que vai executar o ansible foi testada utilizando `Ubuntu 16.04`
 com upgrade atualizado em 18/05/2018 

Para instalar os pacotes necessário, criei um script que auxilia a ter os pacotes exatos.
Basta executar o script bootstrap.sh que está localizado no diretório:
`/idwall-desafios-devops/scripts`  e pronto.

```
cd idwall-desafios-devops/
./scripts/bootstrap.sh
```


### Subindo o cluster
Para subir o cluster, clone este repositório em um diretório de trabalho.

```
git clone git@github.com:rodimes/idwall-desafios-devops.git
```

Após clonar o repo, mude para o diretório de trabalho `ansible` e configure o arquivo hosts.
```
cd idwall-desafios-devops/ansible
vi hosts
``` 
```
[legadasa_wordpress]
172.42.42.11 ansible_user=<Nome do usuario ssh> ansible_ssh_private_key_file="Path com o caminho e nome da chave privada para acesso ssh"


[legadasa_wordpress:vars]
ansible_python_interpreter=/usr/bin/python3
```

Para subir o cluster utilizando o `Vagrant`, modifique os seguintes campos:

De: `ansible_user=` para: `ansible_user=vagrant`


De: `ansible_ssh_private_key_file=` para `ansible_ssh_private_key_file="/home/rodrigo/development/projects/pessoal/idwall-desafios-devops/.vagrant/machines/legadasa-wordpress/virtualbox/private_key"`

```
[legadasa_wordpress]
172.42.42.11 ansible_user=vagrant ansible_ssh_private_key_file="/home/rodrigo/development/projects/pessoal/idwall-desafios-devops/.vagrant/machines/legadasa-wordpress/virtualbox/private_key"

[legadasa_wordpress:vars]
ansible_python_interpreter=/usr/bin/python3
 
``` 

*** Observação: *** Note que no meu caso o ansible_ssh_private_key_file é o Path que o vagrant criou a chave de acesso ssh.


Após alterar o arquivo hosts, mude para a raiz dp diretório de trabalho e execute `./run.sh`

```
cd idwall-desafios-devops/
./run.sh
```

O Vagrant irá fazer start de uma máquina com um node configurado.

A máquina criada seguirá a seguinte descrição:

| NAME               | IP ADDRESS   | ROLE           |
| ---                | ---          | ---            |
| legadasa-wordpress | 172.42.42.11 | Cluster Master |


Depois que o `run.sh` estiver completo, o seguinte comando e saída devem ser
visíveis no cluster master (** legadasa-wordpress **).

```
vagrant ssh legadasa-wordpress
kubectl -n kube-system get po -o wide

NAME                                    READY     STATUS    RESTARTS   AGE       IP          NODE
etcd-ubuntu-xenial                      1/1       Running   0          57m       10.0.2.15   ubuntu-xenial
kube-apiserver-ubuntu-xenial            1/1       Running   0          57m       10.0.2.15   ubuntu-xenial
kube-controller-manager-ubuntu-xenial   1/1       Running   0          56m       10.0.2.15   ubuntu-xenial
kube-dns-86f4d74b45-zt9nz               3/3       Running   0          57m       10.32.0.4   ubuntu-xenial
kube-proxy-6768h                        1/1       Running   0          57m       10.0.2.15   ubuntu-xenial
kube-scheduler-ubuntu-xenial            1/1       Running   0          57m       10.0.2.15   ubuntu-xenial
weave-net-9nh6g                         2/2       Running   0          57m       10.0.2.15   ubuntu-xenial
```

Observação: As vezes apesar do ansible estar informando que executou a exportação da variavel KUBECONFIG 
para que qualquer usuário acesse os comandos do kubernetes, o mesmo não está aplicando, e o seguinte erro aparece:

`The connection to the server localhost:8080 was refused - did you specify the right host or port?`

Se isso acontecer, rode o seguinte comando:

```
sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf

```

Isso irá resolver. Execute novamente `kubectl -n kube-system get po -o wide` . 

Para verificar os pods que foram gerados, execute o seguinte comando: 
```
vagrant@ubuntu-xenial:~$ kubectl get pods
NAME                              READY     STATUS    RESTARTS   AGE
wordpress-7bdfd5557c-vtp6m        1/1       Running   0          1h
wordpress-mysql-bcc89f687-797br   1/1       Running   0          1h
```

```
vagrant@ubuntu-xenial:~$ kubectl get deployment
NAME              DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
wordpress         1         1         1            1           1h
wordpress-mysql   1         1         1            1           1h
```

### Acessando o serviço
Para verificar os serviços que foram gerados, execute o seguinte comando:

```
kubectl get service
NAME              TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)        AGE
kubernetes        ClusterIP      10.96.0.1        <none>         443/TCP        1h
wordpress         LoadBalancer   10.108.249.219   172.42.42.11   80:30620/TCP   1h
wordpress-mysql   ClusterIP      None             <none>         3306/TCP       1h

```

### Escalando a aplicação
Para fazer auto scaling da aplicação, execute o seguinte comando de exemplo:

Antes: 
```
vagrant@ubuntu-xenial:~$ kubectl get pod
NAME                              READY     STATUS    RESTARTS   AGE
wordpress-7bdfd5557c-vtp6m        1/1       Running   0          1h
wordpress-mysql-bcc89f687-797br   1/1       Running   0          1h

```
Scale: 
```
kubectl scale deployment wordpress --replicas=2
```

Depois: 
```
vagrant@ubuntu-xenial:~$ kubectl get pod
NAME                              READY     STATUS    RESTARTS   AGE
wordpress-7bdfd5557c-7f7dk        1/1       Running   0          3s
wordpress-7bdfd5557c-cr7gq        1/1       Running   0          3s
wordpress-7bdfd5557c-vtp6m        1/1       Running   0          1h
wordpress-mysql-bcc89f687-797br   1/1       Running   0          1h
```

### Acessando a aplicação
A aplicação esta acessivel através do ip: 172.42.42.11 .

```
curl -sSL http://172.42.42.11
```
```
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
	<meta name="viewport" content="width=device-width" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="robots" content="noindex,nofollow" />
	<title>WordPress &rsaquo; Installation</title>
	<link rel='stylesheet' id='buttons-css'  href='http://172.42.42.11/wp-includes/css/buttons.min.css?ver=4.8.3' type='text/css' media='all' />
<link rel='stylesheet' id='install-css'  href='http://172.42.42.11/wp-admin/css/install.min.css?ver=4.8.3' type='text/css' media='all' />
<link rel='stylesheet' id='dashicons-css'  href='http://172.42.42.11/wp-includes/css/dashicons.min.css?ver=4.8.3' type='text/css' media='all' />
</head>
<body class="wp-core-ui language-chooser">
<p id="logo"><a href="https://wordpress.org/" tabindex="-1">WordPress</a></p>
```

Para configurar com DNS, associe o ip 172.42.42.11 ao seu  domínio. No meu caso associe ao meu domínio fastabc.com.br:

```
curl -sSL http://fastabc.com.br
```
```
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
	<meta name="viewport" content="width=device-width" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="robots" content="noindex,nofollow" />
	<title>WordPress &rsaquo; Installation</title>
	<link rel='stylesheet' id='buttons-css'  href='http://172.42.42.11/wp-includes/css/buttons.min.css?ver=4.8.3' type='text/css' media='all' />
<link rel='stylesheet' id='install-css'  href='http://172.42.42.11/wp-admin/css/install.min.css?ver=4.8.3' type='text/css' media='all' />
<link rel='stylesheet' id='dashicons-css'  href='http://172.42.42.11/wp-includes/css/dashicons.min.css?ver=4.8.3' type='text/css' media='all' />
</head>
<body class="wp-core-ui language-chooser">
<p id="logo"><a href="https://wordpress.org/" tabindex="-1">WordPress</a></p>
```

### Subindo o cluster fora do Vagrant
Para subir o cluster fora do `Vagrant`, basta modificar o arquivo hosts para apontar para o servidor que deverá receber o cluster.
```
cd idwall-desafios-devops/ansible
vi hosts
``` 
```
[legadasa_wordpress]
52.201.62.234 ansible_user=ubuntu ansible_ssh_private_key_file="/home/rodrigo/.ssh/rodimes.pem"


[legadasa_wordpress:vars]
ansible_python_interpreter=/usr/bin/python3
```

E também alterar o arquivo all.yml que está no diretório `idwall-desafios-devops/ansible/group_vars` para ter o ip do servidor que deverá receber o cluster.

```

---
kubernetes_cluster_ip: 52.201.62.234

```  


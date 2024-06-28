# Limitador de trafico de rede para um determinado IP

1 - sudo tc qdisc del dev eth0 root

  ```sh
sudo apt-get update
sudo apt-get install iproute2
  ```

2 - Marque os pacotes com iptables:
### Primeiro, vamos marcar os pacotes que estão sendo enviados do IP 192.168.1.220 para o IP 77.83.252.180. ###

```sh
sudo iptables -t mangle -A OUTPUT -s 192.168.1.220 -d 77.83.252.180 -j MARK --set-mark 1
```

3 - Configure o tc para limitar os pacotes marcados:
Agora, vamos usar tc para aplicar a limitação de tráfego aos pacotes que foram marcados.

# Adiciona uma disciplina de fila (qdisc) à interface eth0
```sh
sudo tc qdisc add dev eth0 root handle 1: htb default 10
```
# Adiciona uma classe raiz à qdisc com um limite de 1mbit/s
```sh
sudo tc class add dev eth0 parent 1: classid 1:1 htb rate 1mbit
```
# Adiciona um filtro para limitar os pacotes com a marca 1
```sh
sudo tc filter add dev eth0 protocol ip parent 1:0 prio 1 handle 1 fw flowid 1:1
```

4 - Verifique a Configuração
Para verificar se a configuração foi aplicada corretamente, use os seguintes comandos:
```sh
sudo tc qdisc show dev eth0
sudo tc class show dev eth0
sudo tc filter show dev eth0
```
Remova a Configuração (se necessário)
Se precisar remover a configuração de limitação, use os comandos abaixo:


1 - Remover a regra
```sh
sudo iptables -t mangle -D OUTPUT -s 192.168.1.220 -d 77.83.252.180 -j MARK --set-mark 1
```

6 - Remova a configuração do 'tc':
```sh
sudo tc qdisc del dev eth0 root
```

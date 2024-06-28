#!/bin/bash
# Jean Passos - jean@scsite.com.br

# Arquivo para armazenar as informações de limitações
LIMITE_FILE="/tmp/limites_trafego.txt"

# Função para exibir o menu
menu() {
    echo "Escolha uma opção:"
    echo "1. Limitar tráfego"
    echo "2. Excluir limitação de tráfego"
    echo "3. Mostrar limitações atuais"
    echo "4. Sair"
    read -p "Opção: " opcao
}

# Função para limitar o tráfego
limitar_trafego() {
    read -p "Digite o IP de origem: " ip_origem
    read -p "Digite o IP de destino: " ip_destino
    read -p "Digite o nome da interface de rede (ex: eth0): " interface
    read -p "Digite o limite de tráfego (ex: 1mbit): " limite

    sudo iptables -t mangle -A OUTPUT -s $ip_origem -d $ip_destino -j MARK --set-mark 1
    sudo tc qdisc add dev $interface root handle 1: htb default 10
    sudo tc class add dev $interface parent 1: classid 1:1 htb rate $limite
    sudo tc filter add dev $interface protocol ip parent 1:0 prio 1 handle 1 fw flowid 1:1

    # Armazena a limitação no arquivo
    echo "$ip_origem -> $ip_destino : $limite" >> $LIMITE_FILE

    echo "Limitação de tráfego configurada com sucesso!"
}

# Função para excluir a limitação de tráfego
excluir_limitacao() {
    read -p "Digite o IP de origem que deseja remover a limitação: " ip_origem
    read -p "Digite o IP de destino que deseja remover a limitação: " ip_destino
    read -p "Digite o nome da interface de rede (ex: eth0): " interface

    sudo iptables -t mangle -D OUTPUT -s $ip_origem -d $ip_destino -j MARK --set-mark 1
    sudo tc qdisc del dev $interface root

    # Remove a limitação do arquivo
    sed -i "/$ip_origem -> $ip_destino/d" $LIMITE_FILE

    echo "Limitação de tráfego removida com sucesso!"
}

# Função para mostrar as limitações atuais
mostrar_limitacoes() {
    read -p "Digite o nome da interface de rede (ex: eth0): " interface
    echo ""
    echo "=== Disciplinas de Fila (qdisc) ==="
    sudo tc qdisc show dev $interface
    echo ""
    echo "=== Classes de Tráfego ==="
    sudo tc class show dev $interface
    echo ""
    echo "=== Filtros de Tráfego ==="
    sudo tc filter show dev $interface
    echo ""
    echo "=== Regras do iptables ==="
    sudo iptables -t mangle -L OUTPUT -v -n
    echo ""
    echo "=== Limitações Configuradas ==="
    echo "IP de Origem -> IP de Destino : Limite"
    if [ -f $LIMITE_FILE ]; then
        cat $LIMITE_FILE
    else
        echo "Nenhuma limitação configurada."
    fi
    echo ""
}

# Loop principal
while true; do
    menu
    case $opcao in
        1)
            limitar_trafego
            ;;
        2)
            excluir_limitacao
            ;;
        3)
            mostrar_limitacoes
            ;;
        4)
            echo "Saindo..."
            break
            ;;
        *)
            echo "Opção inválida. Tente novamente."
            ;;
    esac
done

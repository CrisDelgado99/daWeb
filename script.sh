#!/bin/bash

# Paso 1 => Actualizo los paquetes del sistema (primer paso al antes de instalar o cambiar cualquier cosa)
sudo apt-get update
sudo apt-get upgrade -y

# Paso 2 => Instalo open jdk
sudo apt install -y openjdk-17-jdk

# Paso 3 => Creo un nuevo usuario tomcat
sudo useradd -m -d /opt/tomcat -U -s /bin/false tomcat

# Paso 4 => Me dirijo al directorio /tmp
cd /tmp

# Paso 5 => Descargo e instalo la versión 10.1.18 de Apache Tomcat
sudo wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.18/bin/apache-tomcat-10.1.18.tar.gz 

# Paso 6 => Descomprimo el archivo que he descargado y lo muevo a /opt/tomcat
sudo tar xzvf apache-tomcat-10*tar.gz -C /opt/tomcat --strip-components=1

# Paso 7 => Vuelvo a root
cd ~

# Paso 8 => Configurar los permisos
sudo chown -R tomcat:tomcat /opt/tomcat/
sudo chmod -R u+x /opt/tomcat/bin

# Paso 9 => Agrego roles y usuarios modificando el archivo tomcat-users.xml
sudo tee /opt/tomcat/conf/tomcat-users.xml <<EOF
<role rolename="manager-gui" />
<user username="manager" password="manager_password" roles="manager-gui" />

<role rolename="admin-gui" />
<user username="admin" password="admin_password" roles="manager-gui,admin-gui" />
EOF

# Paso 10 => Comento la etiqueta <Valve> en el archivo context.xml (Estaba en el archivo 
# y no quiero utilizarla)
sudo sed -i '/<Valve/,/<\/Valve>/ s/^/<!--/' /opt/tomcat/webapps/manager/META-INF/context.xml
sudo sed -i '/<Valve/,/<\/Valve>/ s/$/-->/' /opt/tomcat/webapps/manager/META-INF/context.xml

# Paso 10 => Obtengo la ruta del directorio de instalación de Java (JAVA_HOME)
java_home=$(sudo update-java-alternatives -l | awk '{print $3}')

# Paso 11 => Añado estas líneas a tomcat.service:

sudo tee /etc/systemd/system/tomcat.service <<EOF
[Unit]
Description=Tomcat
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat

Environment="JAVA_HOME=$java_home"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Paso 12 => Reinicio el Daemon
sudo systemctl daemon-reload

# Paso 13 => Reinicio el servicio Tomcat 
sudo systemctl start tomcat

# Paso 14 => Habilito el servicio Tomcat para que se inicie el arranque
sudo systemctl enable tomcat

# Paso 15 => Permito el tráfico en el puerto 8080
sudo ufw allow 8080

# Mensaje de éxito:
echo "Se ha completado la instalación. Puedes acceder a tomcat usando el siguiente enlace:"
echo "http://your_server_ip:8080"
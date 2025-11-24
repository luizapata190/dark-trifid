# 🔧 Cambio de Puerto 8001 → 80

## Cambios Realizados

Se ha modificado la configuración para que la aplicación escuche en el **puerto 80** (HTTP estándar) en lugar del puerto 8001.

### ✅ Archivos Modificados

1. **`docker-compose.yml`**
   - Puerto cambiado de `8001:80` a `80:80`

2. **`setup-ec2.sh`**
   - Mensaje actualizado para mostrar URL en puerto 80

## 🚀 Cómo Aplicar los Cambios en tu Servidor EC2

### Opción 1: Actualizar el Repositorio y Redesplegar

```bash
# Conectarse a EC2
ssh -i tu-key.pem ec2-user@3.18.230.112

# Navegar al proyecto
cd dark-trifid/

# Detener contenedores actuales
sudo docker compose down

# Actualizar código desde GitHub
git pull origin main

# Reconstruir y lanzar con nuevo puerto
sudo docker compose up --build -d

# Verificar que está corriendo
sudo docker compose ps
```

### Opción 2: Editar Manualmente (Si no has subido cambios a GitHub)

```bash
# Conectarse a EC2
ssh -i tu-key.pem ec2-user@3.18.230.112

# Navegar al proyecto
cd dark-trifid/

# Detener contenedores
sudo docker compose down

# Editar docker-compose.yml
nano docker-compose.yml

# Buscar la línea:
#   - "8001:80"
# Cambiarla por:
#   - "80:80"

# Guardar (Ctrl+O, Enter, Ctrl+X)

# Lanzar con nuevo puerto
sudo docker compose up --build -d
```

## 🔍 Verificación

### 1. Verificar que los contenedores están corriendo

```bash
sudo docker compose ps
```

Deberías ver algo como:
```
NAME                      STATUS    PORTS
dark-trifid-frontend      Up        0.0.0.0:80->80/tcp
dark-trifid-backend       Up        0.0.0.0:8000->8000/tcp
```

### 2. Probar acceso local desde EC2

```bash
curl http://localhost
```

### 3. Probar acceso desde tu navegador

Abre tu navegador y ve a:
```
http://3.18.230.112
```

**Ya NO necesitas** especificar el puerto `:8001`

## 🔐 Verificar Security Group

Asegúrate de que el **puerto 80** esté abierto en tu Security Group de AWS:

### Desde AWS Console

1. Ve a **EC2 Dashboard**
2. Selecciona tu instancia
3. Ve a la pestaña **Security**
4. Click en el **Security Group**
5. Verifica que exista una regla **Inbound** para:
   - **Type**: HTTP
   - **Protocol**: TCP
   - **Port Range**: 80
   - **Source**: 0.0.0.0/0 (o tu IP específica)

### Desde AWS CLI

```bash
# Obtener el Security Group ID de tu instancia
aws ec2 describe-instances \
    --instance-ids i-TU-INSTANCE-ID \
    --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' \
    --output text

# Agregar regla para puerto 80 (si no existe)
aws ec2 authorize-security-group-ingress \
    --group-id sg-XXXXXXXXX \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0
```

## 🐛 Troubleshooting

### Error: "Permission denied" al usar puerto 80

El puerto 80 requiere privilegios de root. Por eso usamos `sudo` con Docker Compose.

**Solución**: Siempre usar `sudo` para comandos de Docker Compose:
```bash
sudo docker compose up -d
sudo docker compose down
sudo docker compose logs -f
```

### El sitio no carga en http://3.18.230.112

1. **Verificar que los contenedores están corriendo**:
   ```bash
   sudo docker compose ps
   ```

2. **Ver logs de errores**:
   ```bash
   sudo docker compose logs -f frontend
   ```

3. **Verificar que el puerto está escuchando**:
   ```bash
   sudo netstat -tlnp | grep :80
   ```

4. **Verificar Security Group** (ver sección anterior)

### Conflicto de puerto 80

Si hay otro servicio usando el puerto 80:

```bash
# Ver qué está usando el puerto 80
sudo lsof -i :80

# O con netstat
sudo netstat -tlnp | grep :80
```

Si es Apache o Nginx, detenerlos:
```bash
sudo systemctl stop httpd    # Apache en Amazon Linux
sudo systemctl stop nginx    # Nginx
```

## 📝 Comandos Útiles

```bash
# Ver logs en tiempo real
sudo docker compose logs -f

# Ver solo logs del frontend
sudo docker compose logs -f frontend

# Reiniciar solo el frontend
sudo docker compose restart frontend

# Reconstruir sin caché
sudo docker compose build --no-cache
sudo docker compose up -d

# Ver puertos en uso
sudo docker compose ps
sudo netstat -tlnp
```

## ✅ Resultado Esperado

Después de aplicar los cambios:

- ✅ Acceso directo: `http://3.18.230.112`
- ✅ Sin necesidad de especificar puerto
- ✅ Puerto estándar HTTP (80)
- ✅ Más profesional y fácil de recordar

---

**Fecha**: 2025-11-24  
**Versión**: 1.0

# ============================
# Stage 1 - Build Angular App
# ============================

FROM node:18-alpine AS builder
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build -- --configuration production


# ============================
# Stage 2 - Nginx
# ============================

FROM nginx:1.27-alpine

COPY --from=builder /app/dist/ai-hmis-frontend/browser /usr/share/nginx/html

RUN cat > /etc/nginx/conf.d/default.conf <<'EOF'
server {

    listen 80;

    server_name _;

    root /usr/share/nginx/html;

    index index.html;

    location / {

        try_files $uri $uri/ /index.html;

    }

}
EOF

EXPOSE 80

CMD ["nginx","-g","daemon off;"]

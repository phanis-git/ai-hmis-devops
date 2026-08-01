# ============================
# Stage 1 - Build Angular App
# ============================

FROM node:18-alpine AS builder
WORKDIR /app
COPY --from=app . .
RUN npm install
RUN npm run build -- --configuration production


# ============================
# Stage 2 - Nginx
# ============================

FROM nginx:1.27-alpine

COPY --from=builder /app/dist/ai-hmis-frontend/browser /usr/share/nginx/html

COPY --from=nginx nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx","-g","daemon off;"]

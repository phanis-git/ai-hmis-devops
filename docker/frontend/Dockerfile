# ============================
# Stage 1 - Build Angular App
# ============================

FROM node:14-alpine AS builder
WORKDIR /app 
COPY . .
RUN npm install
RUN npm run build -- --configuration production


# ============================
# Stage 2 - Nginx
# ============================

FROM nginx:1.27-alpine

COPY --from=builder /app/dist/ai-hmis-frontend/browser /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx","-g","daemon off;"]

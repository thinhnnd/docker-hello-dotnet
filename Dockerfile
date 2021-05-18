#Chọn image nào để làm base image 
FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base
WORKDIR /app

#Mở port 5000 trên container  
EXPOSE 5000

#Set biến môi trường 
ENV ASPNETCORE_URLS=http://+:5000

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

#Chọn image nào để làm build image
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
#Copy file csproj trước để chạy lệnh restore. 
COPY ["docker-hello-dotnet.csproj", "./"]
RUN dotnet restore "docker-hello-dotnet.csproj"
#Copy toàn bộ file (ngoại trừ những file được add trong .dockerignore) vào thư mục /src trong biến WORKDIR
COPY . .
WORKDIR "/src/."
#Chạy lệnh build và xuất file ra /src/app/build
RUN dotnet build "docker-hello-dotnet.csproj" -c Release -o /app/build

FROM build AS publish
#Chạy lệnh publish để xuất các file publish ra thư mục /src/app/publish trên container 
RUN dotnet publish "docker-hello-dotnet.csproj" -c Release -o /app/publish

#Từ image base ở line 2
FROM base AS final
# Tạo thư mục app làm thư mục làm việc chính
WORKDIR /app
#Copy từ thư mục /src/publish được tạo ở trên vào thư mục /app của image final
COPY --from=publish /app/publish .
#Chạy dot net app lên 
ENTRYPOINT ["dotnet", "docker-hello-dotnet.dll"]

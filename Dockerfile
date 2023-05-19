FROM mcr.microsoft.com/dotnet/aspnet:2.1 AS base
WORKDIR /app
EXPOSE 5000

ENV ASPNETCORE_URLS=http://+:5000

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:2.1 AS build
WORKDIR /src
COPY ["Core_HelloWorld/Core_HelloWorld.csproj", "Core_HelloWorld/"]
RUN dotnet restore "Core_HelloWorld/Core_HelloWorld.csproj"
COPY . .
WORKDIR "/src/Core_HelloWorld"
RUN dotnet build "Core_HelloWorld.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Core_HelloWorld.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Core_HelloWorld.dll"]

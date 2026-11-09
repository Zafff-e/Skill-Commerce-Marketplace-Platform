FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy project files and restore centrally
COPY Directory.Build.props Directory.Packages.props global.json ./
COPY src/SkillCommerce.Domain/SkillCommerce.Domain.csproj src/SkillCommerce.Domain/
COPY src/SkillCommerce.Application/SkillCommerce.Application.csproj src/SkillCommerce.Application/
COPY src/SkillCommerce.Infrastructure/SkillCommerce.Infrastructure.csproj src/SkillCommerce.Infrastructure/
COPY src/SkillCommerce.Api/SkillCommerce.Api.csproj src/SkillCommerce.Api/

RUN dotnet restore src/SkillCommerce.Api/SkillCommerce.Api.csproj

# Copy full source and build
COPY src/ src/
WORKDIR /src/src/SkillCommerce.Api
RUN dotnet publish -c Release -o /app/publish --no-restore

# Final runtime image
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "SkillCommerce.Api.dll"]


# Setup PostgreSQL Provider After RDS Database is Provisioned
terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
     }
  }
}
provider "postgresql" {
    host            = var.db_host
    port            = 5432
    username        = var.database_username
    password        = var.database_password
    superuser = false
}
# Create App User
resource "postgresql_role" "pitstop_role" {
  name = "pitstop_role"
}
resource "postgresql_role" "application_role" {
    name                = var.sandbox_database_username
    login               = true
    password            = var.sandbox_database_password
    encrypted_password  = true
    roles               = [postgresql_role.pitstop_role.name]
    #depends_on          = aws_db_instance.dev_db
}
# Create Database 
resource "postgresql_database" "sandbox_db" {
    name              = var.sandbox_database_name
    template          = "template0"
    lc_collate        = "C"
    connection_limit  = -1
    allow_connections = true
}
#Create ready-only role
resource "postgresql_grant" "grant_ro_tables" {
  database    = var.sandbox_database_name
  role        = postgresql_role.application_role.name
  schema      = "public"
  object_type = "table"
  #objects     = ["DataElement", "DataElementPersona", "Enrolment", "EnterpriseSystem", "MessageStore", "migrations", "Notification", "Organization", "OrganizationPersona", "Persona", "Stack", "Subscription", "SystemStatus", "ThirdPartyLookup", "TradeTrustKey", "UseCase", "UseCasePersona", "User", "VerificationFlow"]
  #privileges  = ["SELECT"," INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "TRIGGER", "CREATE", "TEMPORARY", "EXECUTE"]
  privileges  = ["SELECT", "UPDATE"]
}

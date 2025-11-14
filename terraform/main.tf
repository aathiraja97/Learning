# Enable required APIs
resource "google_project_service" "enable_apis" {
  for_each = toset([
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com"
  ])

  project = var.project_id
  service = each.key
}

##############
# Artifact Registry
##############
resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = var.region
  repository_id = "gke-test-repo"
  format        = "DOCKER"
  description   = "Docker repo for GKE test app"
}

##############
# GKE Cluster
##############
resource "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  networking_mode = "VPC_NATIVE"
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  cluster    = google_container_cluster.gke.name
  location   = google_container_cluster.gke.location
  node_count = 2

  node_config {
    machine_type = "e2-medium"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

##############
# Jenkins Service Account
##############
resource "google_service_account" "jenkins" {
  account_id   = "jenkins-sa"
  display_name = "Jenkins Service Account"
}

# Generate SA key automatically
resource "google_service_account_key" "jenkins_key" {
  service_account_id = google_service_account.jenkins.name
}

# Save SA Key locally (JSON)
resource "local_file" "jenkins_sa_key_file" {
  content  = base64decode(google_service_account_key.jenkins_key.private_key)
  filename = "${path.module}/jenkins-sa-key.json"
}

##############
# IAM Roles for Jenkins
##############
resource "google_project_iam_member" "artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.jenkins.email}"
}

resource "google_project_iam_member" "gke_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.jenkins.email}"
}

resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.jenkins.email}"
}

output "cluster_name" {
  value = google_container_cluster.gke.name
}

output "cluster_zone" {
  value = google_container_cluster.gke.location
}

output "artifact_registry_repo" {
  value = "${google_artifact_registry_repository.repo.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}"
}

output "jenkins_sa_email" {
  value = google_service_account.jenkins.email
}

output "jenkins_sa_key_file" {
  value       = local_file.jenkins_sa_key_file.filename
  description = "Path to generated Jenkins SA JSON key"
}

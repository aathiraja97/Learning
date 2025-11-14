pipeline {
  agent any
  environment {
    PROJECT = credentials('GCP_PROJECT') // optional credential containing project id
    GCP_SA_KEY = credentials('GCP_SA_KEY') // JSON service account key
    ARTIFACT_REPO = credentials('ARTIFACT_REGISTRY_REPO') // e.g. us-central1-docker.pkg.dev/your-project/gke-test-repo
    IMAGE_NAME = "${env.ARTIFACT_REPO}/gke-test-app"
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Set up GCloud') {
      steps {
        // write service account key to file
        sh '''
          echo "$GCP_SA_KEY" > /tmp/gcp-key.json
          gcloud auth activate-service-account --key-file=/tmp/gcp-key.json
          gcloud config set project ${PROJECT}
          gcloud auth configure-docker ${ARTIFACT_REPO%%/*} --quiet
        '''
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          // use short commit hash for tag
          def tag = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
          env.IMAGE_TAG = "${IMAGE_NAME}:${tag}"
        }
        sh '''
          docker build -t ${IMAGE_TAG} .
        '''
      }
    }

    stage('Push Image') {
      steps {
        sh '''
          docker push ${IMAGE_TAG}
        '''
      }
    }

    stage('Deploy to GKE') {
      steps {
        sh '''
          # get credentials for kubectl (replace zone & cluster if needed)
          gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${CLUSTER_ZONE} --project ${PROJECT}
          # replace image placeholder in k8s manifest and apply
          sed "s|REPLACE_IMAGE|${IMAGE_TAG}|g" k8s/deployment.yaml > /tmp/deploy.yaml
          kubectl apply -f k8s/namespace.yaml || true
          kubectl apply -f /tmp/deploy.yaml
        '''
      }
    }
  }
  post {
    always {
      sh 'rm -f /tmp/gcp-key.json'
    }
  }
}
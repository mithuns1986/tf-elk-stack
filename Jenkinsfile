pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
    stage('TF Plan') {
       steps {
         //withAWS(roleAccount:'818682305270', role:'jenkins-cross-account-role-ss-sgtradex') {
           withAWS(credentials: "dev-cdi-aws", region: 'ap-southeast-1'){
         script {
           sh 'rm -rf .terraform'
           sh "terraform init -upgrade -get=true -input=false -no-color -backend-config='bucket=sgtradex-elk-stack-bucket' -backend-config='key=${params.Environment}/${params.Environment}-pitstop.tfstate'"
           sh "terraform plan -input=false  -no-color -refresh=true -var='pitstop_license_key=${params.pitstopLicenseKey}' -var='sandbox_pitstop_license_key=${params.sandboxpitstopLicenseKey}' -var='environment=${params.Environment}' -var='pitstop_name=${params.Pitstop_Name}' -var-file='${params.Environment}-pitstop.tfvars' -out='${workspace}/plan'"
           //Enable below line to destroy nothing to add extra
           //sh "terraform plan -destroy -input=false  -no-color -refresh=true  -var='pitstop_license_key=${params.pitstopLicenseKey}' -var='sandbox_pitstop_license_key=${params.sandboxpitstopLicenseKey}' -var='environment=${params.Environment}' -var='pitstop_name=${params.Pitstop_Name}' -var-file='${params.Environment}-pitstop.tfvars' -out='${workspace}/plan'"

         }
         }
       }
     }
    //  stage('Approval') {
    //   steps {
    //     script {
    //       //sh 'echo OK'
    //       input message: 'Would you like to procced with applying these terrafrom changes?',ok: 'Yes'
    //     }
    //   }
    // }
     stage('TF Apply') {
      steps {
        //withAWS(roleAccount:'818682305270', role:'jenkins-cross-account-role-ss-sgtradex') {
          withAWS(credentials: "dev-cdi-aws", region: 'ap-southeast-1'){
        script {
          sh "terraform apply -no-color -input=false '${workspace}/plan'"
        }
        }
      }
    }
  }
}

def call() {

    // Load configuration file from Shared Library resources
    def configText = libraryResource('sonarqube.properties')

    // Parse properties manually to avoid java.util.Properties
    def config = configText.readLines()
        .findAll { line ->
            line.trim() &&
            !line.trim().startsWith('#') &&
            line.contains('=')
        }
        .collectEntries { line ->
            def index = line.indexOf('=')

            def key = line.substring(0, index).trim()
            def value = line.substring(index + 1).trim()

            [(key): value]
        }

    def slackChannel = config['SLACK_CHANNEL_NAME']
    def environment = config['ENVIRONMENT']
    def codeBasePath = config['CODE_BASE_PATH']
    def actionMessage = config['ACTION_MESSAGE']
    def keepApproval = config['KEEP_APPROVAL_STAGE'].toBoolean()

    stage('Clone') {

        echo "Cloning AnsibleSonarQube repository..."

        git(
            url: 'https://github.com/yogiindoria/AnsibleSonarQube.git',
            branch: 'main',
            credentialsId: 'github-credentials'
        )

        echo "Repository cloned successfully."
    }

    stage('User Approval') {

        if (keepApproval) {

            input(
                message: "Do you want to deploy SonarQube to ${environment}?",
                ok: 'Proceed'
            )

        } else {

            echo "Approval stage skipped."
        }
    }

    stage('Playbook Execution') {

        echo "Environment: ${environment}"
        echo "Code Base Path: ${codeBasePath}"

        dir(codeBasePath) {

            withCredentials([
                sshUserPrivateKey(
                    credentialsId: 'vm2-ssh-key',
                    keyFileVariable: 'SSH_KEY',
                    usernameVariable: 'SSH_USER'
                )
            ]) {

                sh '''
                    ansible-playbook \
                    -i inventory.ini \
                    -u "$SSH_USER" \
                    --private-key "$SSH_KEY" \
                    site.yml
                '''
            }
        }

        echo "Ansible playbook execution completed."
    }

    stage('Notification') {

        slackSend(
            channel: slackChannel,
            message: "${actionMessage} Environment: ${environment}"
        )
    }
}
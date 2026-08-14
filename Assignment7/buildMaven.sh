#!/bin/bash

show_help() {
    echo "Usage: ./buildMaven.sh [options]"
    echo
    echo "-a              Generate artifact"
    echo "-i              Install artifact to local repository"
    echo "-s <tool>       Run static code analysis"
    echo "                Tools: checkstyle, findbugs, pmd"
    echo "-t <plugin>     Run unit tests"
    echo "-d              Deploy artifact to Tomcat"
    echo "-h              Show help"
}

TOMCAT_WEBAPPS="/opt/tomcat9/webapps"          
TOMCAT_MANAGER_URL="http://localhost:8080/Spring3HibernateApp/"

deploy_artifact() {
    echo ">> Deploying artifact to Tomcat"

    local war_file
    war_file=$(find target -maxdepth 1 -name "*.war" | head -n 1)

    if [ -z "$war_file" ]; then
        echo "No .war file found in target/. Run '$0 -a' first."
        exit 1
    fi

    if [ -d "$TOMCAT_WEBAPPS" ]; then
        echo ">> Copying $war_file to $TOMCAT_WEBAPPS"

        sudo cp "$war_file" "$TOMCAT_WEBAPPS"

        if [ $? -ne 0 ]; then
            echo ">> Failed to copy WAR to Tomcat."
            exit 1
        fi

        echo ">> WAR copied successfully."

        sudo systemctl restart tomcat9

        if [ $? -ne 0 ]; then
            echo ">> Failed to restart Tomcat 9."
            exit 1
        fi

        echo ">> Deployed successfully. Tomcat will auto-deploy the WAR."

    else
        echo ">> Tomcat webapps directory not found: $TOMCAT_WEBAPPS"
        exit 1
    fi
}

generate_docs() {
    echo ">> Generating project documentation (mvn site)"
    mvn site
    echo ">> Docs available at target/site/index.html"
}

case "$1" in

    -a)
        echo  "Generating artifact..."

        mvn clean package
            
            if [ $? -eq 0 ]; then
                echo "Artifact generated successfully."
            else
                echo "Artifact generation failed."
                exit 1
            fi

        ;;

    -i)
        echo  "Installing artifact to local repository..."

            if mvn clean install; then
                echo "Artifact installed successfully."
            else
                echo "Artifact installation failed."
                exit 1
            fi
        ;;

    -s)
        TOOL="$2"

        case "$TOOL" in

            checkstyle)
                echo "Running Checkstyle..."
                mvn checkstyle:check
                ;;

            findbugs)
                echo "Running FindBugs..."
                mvn findbugs:check
                ;;

            pmd)
                echo "Running PMD..."
                mvn pmd:check
                ;;

            *)
                echo "Invalid static analysis tool: $TOOL"
                echo "Supported tools:"
                echo "  checkstyle"
                echo "  findbugs"
                echo "  pmd"
                exit 1
                ;;

        esac

        ;;
    -t)
        TOOL="$2"

        case "$TOOL" in

                surefire)
                    echo "Running unit tests..."

                    if mvn test; then
                        echo "Unit tests completed successfully."
                    else
                        echo "Unit tests failed."
                        exit 1
                    fi

                    echo "Running Code Coverage..."
                    mvn cobertura:cobertura

                    if [ $? -ne 0 ]; then
                        echo "Code coverage failed."
                        exit 1
                    fi
                ;;

                *)
                    echo "Invalid unit test plugin: $TOOL"
                    echo "Supported plugins: surefire, jacoco"
                    exit 1
                    ;;

            esac
    ;;

    -d)
        deploy_artifact
    ;;

    -c)
        generate_docs
    ;;

    -h)
        show_help
    ;;

    *)
        echo "Invalid option: $1"
        echo
        show_help
        exit 1
        ;;
esac
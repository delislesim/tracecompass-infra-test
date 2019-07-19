pipeline {
	agent {
		kubernetes {
			label 'tracecompass-build'
			defaultContainer 'environment'
			yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: environment
    image: delislesim/eclipse-tracecompass-build-env:16.04
    tty: true
    command: [ "/bin/sh" ]
    args: ["-c", "/home/tracecompass/.vnc/xstartup.sh && cat"]
    resources:
      requests:
        memory: "2.6Gi"
        cpu: "1.3"
      limits:
        memory: "2.6Gi"
        cpu: "1.3"
    volumeMounts:
    - name: settings-xml
      mountPath: /home/jenkins/.m2/settings.xml
      subPath: settings.xml
      readOnly: true
    - name: m2-repo
      mountPath: /home/jenkins/.m2/repository
    - name: tools
      mountPath: /opt/tools
  - name: jnlp
    image: 'eclipsecbi/jenkins-jnlp-agent'
    volumeMounts:
    - mountPath: /home/jenkins/.ssh
      name: volume-known-hosts
  volumes:
  - name: volume-known-hosts
    configMap:
      name: known-hosts
  - name: settings-xml
    configMap: 
      name: m2-dir
      items:
      - key: settings.xml
        path: settings.xml
  - name: m2-repo
    emptyDir: {}
  - name: tools
    persistentVolumeClaim:
      claimName: tools-claim-jiro-tracecompass
"""
		}
	}
	options {
        timestamps()
	    timeout(time: 4, unit: 'HOURS')
		buildDiscarder(logRotator(numToKeepStr:'10'))
	}
	tools {
        maven 'apache-maven-latest'
        jdk 'oracle-jdk8-latest'
    }
	environment {
	    MAVEN_OPTS="-Xms768m -Xmx2048m"
	}
	stages {
		stage('Build') {
			steps {
				git branch: 'master', url: 'git://git.eclipse.org/gitroot/tracecompass/org.eclipse.tracecompass'
                sh 'mvn --version'
                sh 'java -version'
                sh 'echo $HOME'
                // sh 'mvn clean install -Pctf-grammar -Pbuild-rcp -Dmaven.test.error.ignore=true -Dmaven.test.failure.ignore=true -DskipTests -Dmaven.repo.local=/home/jenkins/.m2/repository --settings /home/jenkins/.m2/settings.xml'
                sh 'mvn clean install -Pctf-grammar -Pbuild-rcp -Dmaven.repo.local=/home/jenkins/.m2/repository --settings /home/jenkins/.m2/settings.xml'
			}
			post {
				always {
					archiveArtifacts artifacts: '**/screenshots/*.jpeg,**/target/**/*.log, **/target/**/config.ini, **/rcptt-maven-plugin*.jar', fingerprint: false
                    junit '**/target/surefire-reports/*.xml'
				}
			}
		}
		stage('Deploy') {
			steps {
				container('jnlp') {
					sshagent (['projects-storage.eclipse.org-bot-ssh']) {
						sh 'ssh genie.tracecompass@projects-storage.eclipse.org mkdir -p /home/data/httpd/download.eclipse.org/tracecompass/test_new_ci/rcp/'
                        sh 'ssh genie.tracecompass@projects-storage.eclipse.org mkdir -p /home/data/httpd/download.eclipse.org/tracecompass/test_new_ci/rcp-repository/'
                        sh 'ssh genie.tracecompass@projects-storage.eclipse.org mkdir -p /home/data/httpd/download.eclipse.org/tracecompass/test_new_ci/repository/'
                        sh 'ssh genie.tracecompass@projects-storage.eclipse.org rm -rf  /home/data/httpd/download.eclipse.org/tracecompass/test_new_ci/rcp/*'
                        sh 'ssh genie.tracecompass@projects-storage.eclipse.org rm -rf  /home/data/httpd/download.eclipse.org/tracecompass/test_new_ci/rcp-repository/*'
                        sh 'ssh genie.tracecompass@projects-storage.eclipse.org rm -rf  /home/data/httpd/download.eclipse.org/tracecompass/test_new_ci/repository/*'
                        sh 'scp -r rcp/org.eclipse.tracecompass.rcp.product/target/products/trace-compass-* genie.tracecompass@projects-storage.eclipse.org:/home/data/httpd/download.eclipse.org/tracecompass/test_new_ci/rcp/'
                        sh 'scp -r rcp/org.eclipse.tracecompass.rcp.product/target/repository/* genie.tracecompass@projects-storage.eclipse.org:/home/data/httpd/download.eclipse.org/tracecompass/test_new_ci/rcp-repository/'
                        sh 'scp -r releng/org.eclipse.tracecompass.releng-site/target/repository/* genie.tracecompass@projects-storage.eclipse.org:/home/data/httpd/download.eclipse.org/tracecompass/test_new_ci/repository/'
					}
				}
			}
		}
	}
}
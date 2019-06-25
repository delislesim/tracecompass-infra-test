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
    image: mickaelistria/eclipse-acute-build-test-env:test
    tty: true
    command: [ "uid_entrypoint", "cat" ]
    resources:
      requests:
        memory: "2.6Gi"
        cpu: "1.3"
      limits:
        memory: "2.6Gi"
        cpu: "1.3"
  - name: jnlp
    image: 'eclipsecbi/jenkins-jnlp-agent'
    volumeMounts:
    - mountPath: /home/jenkins/.ssh
      name: volume-known-hosts
  volumes:
  - configMap:
      name: known-hosts
    name: volume-known-hosts
"""
		}
	}
	options {
	    timeout(time: 60, unit: 'MINUTES')
		buildDiscarder(logRotator(numToKeepStr:'10'))
	}
	environment {
	    MAVEN_OPTS="-Xms256m -Xmx2048m"
	    M2_REPO="$WORKSPACE/m2-repo"
	}
	stages {
		stage('Build') {
			steps {
				wrap([$class: 'Xvnc', useXauthority: true]) {
					sh 'mvn clean install -Pctf-grammar -Pbuild-rcp -Pbuild-one-rcp -Dmaven.test.error.ignore=true -Dmaven.test.failure.ignore=true -Dcbi.jarsigner.skip=false'
				}
			}
			post {
				always {
					archiveArtifacts artifacts: '**/screenshots/*.jpeg,**/target/**/*.log, **/target/**/config.ini, **/rcptt-maven-plugin*.jar', fingerprint: false
					junit '*/target/surefire-reports/TEST-*.xml' 
				}
			}
		}
	}
}
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
    image: delislesim/eclipse-tracecompass-build-env:test
    tty: true
    command: [ "uid_entrypoint", "cat" ]
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
"""
		}
	}
	options {
	    timeout(time: 4, unit: 'HOURS')
		buildDiscarder(logRotator(numToKeepStr:'10'))
	}
	environment {
	    MAVEN_OPTS="-Xms768m -Xmx2048m"
	}
	stages {
		stage('Build') {
			steps {
				git branch: 'master', url: 'git://git.eclipse.org/gitroot/tracecompass/org.eclipse.tracecompass'
				wrap([$class: 'Xvnc', useXauthority: true]) {
					sh 'mvn clean install -Pctf-grammar -Pbuild-rcp -Dmaven.test.error.ignore=true -Dmaven.test.failure.ignore=true -Dmaven.repo.local=/home/jenkins/.m2/repository --settings /home/jenkins/.m2/settings.xml'
				}
			}
			post {
				always {
					archiveArtifacts artifacts: '**/screenshots/*.jpeg,**/target/**/*.log, **/target/**/config.ini, **/rcptt-maven-plugin*.jar', fingerprint: false
				}
			}
		}
	}
}
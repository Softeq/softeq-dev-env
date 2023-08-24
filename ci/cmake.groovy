#!/usr/bin/env groovy
/*
Create new item in jenkins
Enable "Prepare an environment for the run"
Set "Properties Content" ie
PROJECT_URL= <SSH URI TO THE STASH>
AGENT_LABEL = <JENKINS AGENT TO BUILD ON>
BUILD_CONFIG=<CMAKE BUILD OPTIONS>
SONAR_TOKEN=<HASH FROM SONAR>
CMAKE_IMAGE=<DOCKER IMAGE NAME USED BY PROJECT FOR BUILDS>
CMAKE_TEST_IMAGE=<DOCKER IMAGE NAME USED BY PROJECT FOR TESTS>
*/
pipeline {

    agent {
        label env.AGENT_LABEL
    }

    parameters {
         gitParameter(
          branchFilter: 'origin/(.*)', 
          defaultValue: 'master', 
          selectedValue: 'DEFAULT',
          name: 'BRANCH', 
          quickFilterEnabled: true, 
          type: 'PT_BRANCH', 
          useRepository: env.PROJECT_URL,
          description: 'Branch to checkout from the project repo')
        gitParameter(
          selectedValue: 'NONE',
          name: 'PR_ID',
          defaultValue: '', 
          type: 'PT_PULL_REQUEST', 
          useRepository: env.PROJECT_URL,
          description: 'Pull request ID')
        gitParameter(
          selectedValue: 'NONE',
          branchFilter: 'origin/(.*)', 
          defaultValue: 'master', 
          name: 'BASE_BRANCH', 
          type: 'PT_BRANCH', 
          useRepository: env.PROJECT_URL,
          description: 'Target branch of the pull request')
        booleanParam(
            defaultValue: false, 
            description: 'Clean docker cache', 
            name: 'CLEAN_CACHE'
        )
    }
    environment {
        PATH = "$WORKSPACE/builder/bin:$PATH"
        CMAKE_DOCKER_ARGS = "--rm -h jenkins"
    }
    stages {
        stage ("Update Builder") {
            steps {
                cleanWs()
                dir("builder") {
                    checkout([$class: 'GitSCM',
                            branches: [[name: '*/master']],
                            extensions:
                              [[
                               $class: 'SubmoduleOption', 
                               disableSubmodules: false,
                               parentCredentials: true,
                               recursiveSubmodules: true,
                               reference: '',
                               trackingSubmodules: false
                              ]],
                            userRemoteConfigs: [[credentialsId: 'stash_ssh_credentials_id',
                              url: 'ssh://git@stash.softeq.com:7999/emblab/softeq-dev-env.git']]
                        ])
                    script {
                        if (params.CLEAN_CACHE) {
                            sh """make docker P=--no-cache"""
                        } else {
                            sh """make docker"""
                        }
                    }
                }
            }
        }
        stage ("Update Project") {
            steps {
                dir("sources"){
                        script {
                          checkout([$class: 'GitSCM',
                            branches: [[name: "${params.BRANCH}"]],
                            doGenerateSubmoduleConfigurations: false,
                            extensions: 
                              [[$class: 'CheckoutOption', timeout: 20], 
                              [$class: 'CloneOption',
                                timeout: 20, 'noTags': 'true', 'shallow': 'false', 'honorRefspec': 'true']],
                            gitTool: 'Default',
                            submoduleCfg: [],
                            userRemoteConfigs: [[credentialsId: 'stash_ssh_credentials_id',
                              url: PROJECT_URL]]
                          ])
//, 
//                              refspec: "+refs/heads/${params.BRANCH}:refs/remotes/origin/${params.BRANCH}"
                          if (params.CLEAN_CACHE) {
                            sh """sq-cmake-build docker --no-cache"""
                          } else {
                            sh """sq-cmake-build docker"""
                          }
                        }
                }
            }
        }
        stage ("Build Project") {
            steps {
                dir("sources"){
                    script {
                        sh """sq-cmake-build sonar_build ${BUILD_CONFIG}"""
                    }
                }
            }
        }
        stage ("Test Project") {
            steps {
                dir("sources"){
                    script {
                        sh """CMAKE_IMAGE=${CMAKE_TEST_IMAGE} sq-cmake-build sonar_test"""
                    }
                }
            }
        }
        stage ("Analyze Project") {
//            when { expression { false } }
            steps {
                dir("sources"){
                    script {
                        sh """sq-cmake-build sonar_scan BRANCH=${params.BRANCH} BASE_BRANCH=${params.BASE_BRANCH} PR_ID=${params.PR_ID} SONAR_TOKEN=${SONAR_TOKEN}"""
                    }
                }
            }
        }
        stage ("Check installation") {
            steps {
                dir("sources"){
                    script {
                        sh """
                            sq-cmake-build prod -DCMAKE_INSTALL_PREFIX=examples/out ${env.BUILD_CONFIG}
                            sq-cmake-build install
                            """
                    }
                }
                dir("sources/examples"){
                    script {
                        sh """
                            CMAKE_ENABLE_REGISTRY=false sq-cmake-build dev -DCMAKE_PREFIX_PATH=out
                            """
                    }
                }
            }
        }
    }
    post {
        always {
            dir("sources"){
                archiveArtifacts (
                  artifacts: 'build/sonar/Testing/**/*.xml',
                  fingerprint: true
                )
                xunit (
                  testTimeMargin: '3000',
                  thresholdMode: 1,
                  thresholds: [
                      skipped(unstableThreshold: '3')
                  ],
                  tools: [CTest(
                     pattern: 'build/sonar/Testing/**/*.xml',
                     deleteOutputFiles: true,
                     failIfNotNew: false,
                     skipNoTestFiles: true,
                     stopProcessingIfError: true
                  )]
                )
                script {
       /*             publishHTML([allowMissing: false,
                            alwaysLinkToLastBuild: true,
                            keepAll: false,
                            reportDir: "build/sonar/Coverage",
                            reportFiles: 'index.html',
                            reportName: 'Test Coverage Report',
                 xunit followSymlink: fa
                 lse, thresholds: [skipped(unstableThreshold: '
                 3')], tools: [CTest(excludesPattern
                 : '', failIfNotNew: f
                 alse, pattern: '', stopProcessingIfError: true)]           reportTitles: ''])*/
                    
                    currentBuild.result = currentBuild.result ?: 'SUCCESS'
                    notifyBitbucket()
                }
            }
        }
    }
}

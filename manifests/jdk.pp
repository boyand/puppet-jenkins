# Type jenkins::jdk
#
# Manages jenkins jdk
#
define jenkins::jdk (
  $java_home,
  $ensure = 'present',
){
  validate_string($ensure)

  include ::jenkins::cli_helper

  Class['jenkins::cli_helper'] ->
    Jenkins::Jdk[$title] ->
      Anchor['jenkins::end']

  case $ensure {
    'present': {
      validate_string($java_home)
      # XXX not idempotent
      jenkins::cli::exec { "create-jenkins-jdk-${title}":
        command => [
          'create_or_update_jdk',
          $title,
          $java_home,
        ],
      }
    }
    'absent': {
      # XXX not idempotent
      jenkins::cli::exec { "delete-jenkins-jdk-${title}":
        command => [
          'delete_jdk',
          $title,
        ],
      }
    }
    default: {
      fail "ensure must be 'present' or 'absent' but '${ensure}' was given"
    }
  }
}

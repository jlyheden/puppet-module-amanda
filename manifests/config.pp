define amanda::config (
  $ensure                   = present,
  $configs_directory        = undef,
  $manage_configs_directory = true,
  $configs_source           = 'modules/amanda/server',
  $owner                    = undef,
  $group                    = undef,
  $mode                     = '0644'
) {
  # Workaround to support 2.6
  $config = $::puppetversion ? {
    /2\.6/ => $name,
    default => $title
  }
  include amanda::params
  if $configs_directory != undef {
    $configs_directory_real = $configs_directory
  } else {
    $configs_directory_real = $amanda::params::configs_directory
  }

  if $owner != undef {
    $owner_real = $owner
  } else {
    $owner_real = $amanda::params::user
  }

  if $group != undef {
    $group_real = $group
  } else {
    $group_real = $amanda::params::group
  }

  if ($ensure == 'present') {
    $ensure_directory = 'directory'
  } elsif ($ensure == 'absent') {
    $ensure_directory = 'absent'
  } else {
    fail("invalid ensure parameter: $ensure")
  }

  if (
    $manage_configs_directory
    and !defined(File["amanda::config:$configs_directory_real"])
  ) {
    file { "amanda::config:$configs_directory_real":
      ensure => $ensure_directory,
      path   => $configs_directory_real,
      owner  => $owner_real,
      group  => $group_real,
      mode   => $directory_mode,
    }
  }

  file { "$configs_directory_real/$config":
    ensure  => $ensure_directory,
    owner   => $owner_real,
    group   => $group_real,
    mode    => $mode,
    recurse => remote,
    source  => "puppet://$server/$configs_source/$config"
  }

}

# -*- mode: puppet; -*-

class blueboxnoc::tinc {
      package { 'tinc':
        ensure => 'present',
      }
}

class loja_virtual::web {
	include loja_virtual
	include mysql::client
	include loja_virtual::params

	file { $loja_virtual::params::keystore_file:
		mode		=> 0644,
		source		=> "puppet:///modules/loja_virtual/.keystore",
	}

	class { "tomcat::server":
		connectors	=> [$loja_virtual::params::ssl_connector],
		data_sources	=> {
			"jdbc/web"		=> $loja_virtual::params::db,
			"jdbc/secure"	=> $loja_virtual::params::db,
			"jdbc/storage"	=> $loja_virtual::params::db,
		},
		require		=> File[$loja_virtual::params::keystore_file],
	}

	file { "/var/lib/tomcat7/lib":
		ensure => "directory",
		require		=> Package["tomcat7"],
	}

	file { "/var/lib/tomcat7/lib/mysql-connector-java-5.1.34-bin.jar":
		owner		=> tomcat7,
		group		=> tomcat7,
		mode		=> 0644,
		source		=> "puppet:///modules/loja_virtual/mysql-connector-java-5.1.34-bin.jar",
		require		=> Package["tomcat7"],
	}

	file { "/var/lib/tomcat7/webapps/devopsnapratica.war":
		owner		=> tomcat7,
		group		=> tomcat7,
		mode		=> 0644,
		source		=> "puppet:///modules/loja_virtual/devopsnapratica.war",
		require		=> Package["tomcat7"],
		notify		=> Service["tomcat7"],
	}
	apt::source { 'devopsnapratica':
		location	=> 'http://192.168.33.16/',
		release		=> 'devopspkgs',
		repos		=> 'main',
		key 		=> '6DCA8F3C',
		key_source	=> 'http://192.168.33.16/devopspkgs.gpg',
		include_src	=> false,
	}

	package { "devopsnapratica":
		ensure 	=> "latest",
		notify	=> Service["tomcat7"],
	}
}
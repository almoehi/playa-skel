name := "playa-skel"

version := "1.0-SNAPSHOT"

resolvers ++= Seq(
        "webjars" at "http://webjars.github.com/m2",
        Resolver.url("play-plugin-releases", new URL("http://repo.scala-sbt.org/scalasbt/sbt-plugin-releases/"))(Resolver.ivyStylePatterns),
        Resolver.url("play-plugin-snapshots", new URL("http://repo.scala-sbt.org/scalasbt/sbt-plugin-snapshots/"))(Resolver.ivyStylePatterns),
        Resolver.url("Sonatype Snapshots",url("http://oss.sonatype.org/content/repositories/snapshots/"))(Resolver.ivyStylePatterns),
        Resolver.url("almoehi-releases", new URL("https://github.com/almoehi/releases/"))(Resolver.ivyStylePatterns)
        //Resolver.file("Local Repository", file(sys.env.get("PLAY_HOME").map(_ + "/repository/local").getOrElse("")))(Resolver.ivyStylePatterns)
)

libraryDependencies ++= Seq(
  jdbc,
  anorm,
  cache,
  "org.almoehi" %% "play2-playa" % "1.0-SNAPSHOT"
)     

play.Project.playScalaSettings ++ Seq(
	templatesImport += "play.modules.playa.models._",
	templatesImport += "play.modules.playa.service.LayoutProvider",
	templatesImport += "play.modules.playa.Implicits._",
	templatesImport += "play.modules.playa.service.SiteContext",
	templatesImport += "play.modules.playa.service.Paginator",
	templatesImport += "play.modules.playa.security.SecurityHandler",
	templatesImport += "play.modules.playa.helper.BootstrapFormHelper._",
	templatesImport += "org.joda.time.DateTime"
)

play.Project.playScalaSettings

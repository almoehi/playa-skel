package controllers

import play.api._
import play.api.mvc._
import play.api.data._
import play.api.data.Forms._
import org.joda.time.DateTime
import play.modules.reactivemongo.MongoController
import scala.concurrent.ExecutionContext
import reactivemongo.bson._
import reactivemongo.api.gridfs._
import play.modules.playa._
import play.modules.playa.security._
import scala.concurrent.Future
import securesocial.core.SecuredRequest
import reactivemongo.api.DB
import play.modules.playa.Implicits._
import play.modules.playa.service._
import play.modules.playa.security._
import reactivemongo.api.gridfs.Implicits.DefaultReadFileReader
import play.modules.playa.models.NavigationItem
import play.modules.playa.models.Navigation

object Application extends Controller with MongoController with SecurityActionBuilders with StorageProvider with NavigationProvider {
  
  lazy val siteNav = navigationProvider.getWithNavigation(navigationProvider.defaultSiteNavigationId){
		val nav:Navigation = Navigation(navigationProvider.defaultSiteNavigationId)
		
		nav.addNavigationItems(Map(
		    "/" -> new NavigationItem("Home", "/", None, None, Some(nav), Some(Seq(new NavigationItem("Forms", routes.Application.index.toString), new NavigationItem("Login", "/login")))),
		    "/security" -> new NavigationItem("Security", "/security", None, None, Some(nav), Some(Seq(new NavigationItem("ACL protected", routes.Application.acl.toString), new NavigationItem("Not authorized", "/not-authorized"), new NavigationItem("Always Denied Area", "/denied"))))
		))
		
		nav
  }
  
  lazy val contextNav = navigationProvider.getWithNavigation("customContextNav"){
    Navigation("customContextNav", None,
		  Map(
		      routes.Application.submodule.toString -> NavigationItem("Submodule", routes.Application.submodule.toString),
		      routes.Application.upload.toString -> NavigationItem("File-Upload Test", routes.Application.upload.toString)
		  )
    	)
	}
  
  implicit def ctx(implicit request:RequestHeader) = DefaultSiteContext(Some(siteNav), Some(contextNav))
  
  def index = UserAwareAction { implicit request =>
    	
	    val userName = request.user match {
	        case Some(user) => user.fullName
	        case _ => "guest"
	    }
    	  
	    val testForm = Form(
		  tuple(
		    "email" -> optional(email),
		    "password" -> text,
		    "date" -> default(jodaDate("YYYY-mm-dd"), DateTime.now()),
		    "country" -> optional(text),
		    "tos" -> optional(boolean),
		    "tosList" -> list(text)
		  )
		)
		
		val url = routes.Application.index.absoluteURL()
	    Logger.info("absoluteURL: " + url)

	    testForm.bindFromRequest.fold(
		  formWithErrors => // binding failure, you retrieve the form containing errors,
		    Ok(play.ui.backend.views.html.index("Your new application is ready. You are: " + userName, formWithErrors)),
		  value => // binding success, you get the actual value 
		    Ok(play.ui.backend.views.html.index("Your new application is ready. You are: " + userName, testForm))
		)
  }
  
  def submodule = Action { implicit request => 
    Ok(play.ui.backend.views.html.submodule("Your new application is ready."))
  }
  
  
  def acl = UserWithRolesAction("registered").async { implicit request:SecuredRequest[_] => 
      Future {
        Ok(play.ui.backend.views.html.submodule("Submodule with REGISTERED ACL for user: " + request.user.getIdentifier))
      }
  }
  
  
  def upload = UserAwareAction { implicit request =>
      	val form = Form(
	    		tuple(
	    				"name" -> text,
	    				"userfile1" -> text,
	    				"userfile2" -> optional(text)
	    		)
	    )
	    Ok(play.ui.backend.views.html.upload("Storage Test", form))
  }
  
  def handleUpload = UserAwareAction.async(gridFSBodyParser(gfs)) { implicit request =>
		    val form = Form(
		    		tuple(
		    				"name" -> text,
		    				"userfile1" -> text,
		    				"userfile2" -> optional(text)
		    		)
		    )
		    
		    form.bindFromMultipartRequest(BSONDocument("userfile1" -> BSONDocument("requiredRoles" -> BSONArray("registered")))).map{_.fold(
		    		formWithErrors => Ok(play.ui.backend.views.html.upload("Storage Test", formWithErrors)),
		    		value => {
		    		  request.user match {
		    		    case Some(u) => 
		    		      play.modules.playa.service.UserProvider.update(u.copy(avatarUrl = Some(controllers.routes.StorageController.imageItem(value._2).url)))
		    		    case _ => None
		    		  }
		    		  Ok(play.ui.backend.views.html.upload("Storage Test", form.fill(value)))
		    		}
		    )}
    }
}
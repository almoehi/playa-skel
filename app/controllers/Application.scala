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
  
  implicit def ctx(implicit request:RequestHeader) = DefaultSiteContext(navigationProvider.get(navigationProvider.defaultSiteNavigationId), None)
  
  def index = Action {implicit request =>
    Ok(views.html.index("Your new application is ready."))
  }
}
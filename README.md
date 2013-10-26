play2-playa project template
=====================================
This project sets up a play-2.2 application with play2-playa module.

Playa is a custom and extended Play-2.2
Playa provides additional features 
Playa is indented to provide some basic infrastructure for Play! Framework to speed up project development. It uses some popular Play! modules and contains several custom extensions.

Playa! provides the following features:
=======================================
- Security as provided by deadbolt2 module
- Authorization as provided by securesocial2 module
- Reactive MongoDB driver as provided by reactivemongo
- A slick ready2use AdminUI-Theme based on Bootstrap3 as provided by Bootstrap-Admin-Template
- Custom storage subsystem to easily receive, store and serve files and file uploads


Additional components and extensions:
--------------------------
- Navigation as provided by a custom NavigationManager plugin
- Support for Bootstrap3 forms
- custom form field helpers for file and image uploads (integrates perfect with storage subsystem)
- A bunch of custom form field helpers to support additional and extended form controlls (taglist, multiselect drop-down, date-picker, time-picker, color-picker, masked inputs, ...)
- Custom actions builders to easily access current user object and secure your actions based on user roles
- MongoDB based UserProvider to store user accounts and user roles
- An async storage subsystem (based on gridFS) to remove the pain from handling and serving file uploads from multipart form requests
- Seamless integration of security and storage subsystem allows securing of storage items with user roles
- A simple pagination implementation to build views with paged data


SiteContext
========================
Playa uses a concept called _SiteContext_ to provide features like navigation and access of current user within templates. Therefore, an `implicit ctx:SiteContext` implicit needs to be present in any Admin-UI template. You can simply provide it from inside your controllers like this:

	implicit def ctx(implicit request:RequestHeader) = DefaultSiteContext(Some(siteNav), Some(contextNav))
	
Where `siteNav` and `contextNav` are instances of `Navigation` to provide a (custom) navigation tree. To simplify this task the `NavigationProvider` trait provides a `defaultSiteContext` which you can use like this:

	implicit def ctx(implicit request:RequestHeader) = navigationProvider.defaultSiteContext

If you don't need the navigation plugin and are not using the provided Admin-UI template(s) you can ommit this implicit.


Controller Traits
========================
Each module can be used by simply extending your controller with the provided traits.

	object PlayaWelcome extends Controller with MongoController with SecurityActionBuilders with StorageProvider with NavigationProvider {
	
	}

*	**MongoController:** grants access to mongodb (see [Play-ReactiveMongo](https://github.com/ReactiveMongo/Play-ReactiveMongo))
*   **SecurityActionBuilder:** provides UserWithRoles, UserAwareAction, UserAction action builders
*	**StorageProvider:** provides a simple to use storage subsystem based on gridFS. Receive, store and serve data or file-uploads
*	**NavigationProvider:** provides access to `navigationProvider` property and the `defaultSiteContext`


MongoDB
========
Access to MongoDB and GridFS is powered by the async [ReactiveMongo](http://reactivemongo.org/) driver.

Security
========
Security subsystem is powered by the [Deadbolt2](https://github.com/schaloner/deadbolt-2-guide) module. However, Playa comes with it's own custom ActionBuilders and template helpers. Your controller needs to extend from the `SecurityActionBuilders` trait.

Secure an action - user requires at least one of given roles

	def acl = UserWithRolesAction("registered").async { implicit request => 
      Future {
        Ok(play.ui.backend.views.html.submodule("Submodule with REGISTERED ACL for user: " + request.user.getIdentifier))
      }
	}

Secure with role groups - user requires at least one role of each given role group

	def acl = UserWithRolesAction(List(Seq("registered"))).async { implicit request => 
      Future {
        Ok(play.ui.backend.views.html.submodule("Submodule with REGISTERED ACL for user: " + request.user.getIdentifier))
      }
	}
	

Authorization /w OAuth Support
==============================
Authorization is provided by the [securesocial2](http://securesocial.ws) module. Guides and docs on how to use it are available on the [securesocial](http://securesocial.ws) website.

Playa comes with a UserProvider implementation which stores all users and user roles in MongoDB. Playa supports implicit type conversions between securesocial2 Identity and the Playa user model by importing:

	import play.modules.playa.Implicits._
	
secure action with (logged in) user

	def acl = UserAction.async { implicit request => 
      Future {
        Ok(play.ui.backend.views.html.submodule("Submodule with logged-in user: " + request.user.getIdentifier))
      }
	}
	

action with an optional user

	def acl = UserAwareAction.async { implicit request => 
	  val userName = request.user match {
	        case Some(user) => user.fullName
	        case _ => "guest"
	    }
	    
      Future {
        Ok(play.ui.backend.views.html.submodule("Submodule with logged-in user: " + userName))
      }
	}
	
	
Bootstrap3 forms 
=================
Playa provides a default form field constructor to create forms using the Bootstrap3 markup rules.

Custom form field helpers
==========================
Playa provides the following custom form field helpers. These helpers support the following default field options as the original Play! field helpers:

- **_label**: label text or omit for no label
- **class**: add custom CSS classes to input tag `class=""` property
- **placeholder**: placeholder value e.g. for text inputs or an image URL for image fields
- **tooltip**: tooltp text
- **_offset**: apply a bootstrap column offset - this adds a bootstrap CSS class like  `col-lg-offset-X` - useful to align form fields. When mixing forms with labels and no labels use `_offset -> 2` on fields without labels

List of supported form field helpers:


* `@fieldCheckbox(field = myForm("fieldName"))`
* `@fieldCurrency(field = myForm("fieldName"), 'mask -> "999.999,99", 'currency -> "EUR")`
* `@fieldDatepicker(field = myForm("fieldName"))`
* `@fieldEmail(field = myForm("fieldName"), 'tooltip -> "Give your email", 'placeholder -> "Your Email")`
* `@fieldFile(field = myForm("userFile"), 'selectButton -> "select file", 'removeButton -> "reset", 'deleteText -> "delete current file")`
* `@fieldHexColor(field = myForm("fieldName"))`
* `@fieldRgbColor(field = myForm("fieldName"))`
* `@inputHidden(field = myForm("fieldName"))`
* `@fieldImage(field = myForm("imageFile"), 'placeholder -> "some/empty/url", 'selectButton -> "select image", 'removeButton -> "reset", 'deleteText -> "remove current image")`
* `@fieldLimitedTextarea(field = myForm("fieldName"), 'limit -> 140, 'remainingText -> "%n remaining", 'limitText -> "max %n chars")`
* `@fieldMultiSelect(field = myForm("fieldName"), options = List(("de", "Germany"), ("ca", "Canada")))`
* `@fieldPassword(field = myForm("fieldName"), 'size -> 10, 'tooltip = "some tooltip")`
* `@fieldRadio(field = myForm("fieldName"), 'tooltip -> "radio button text")`
* `@fieldSelect(field = myForm("fieldName"), options = options(List("Yes","No")), args = 'placeholder -> "choose value")`
* `@fieldSpinner(field = myForm("fieldName"), 'step -> 1, 'numberFormat -> "n", 'min -> 0, 'max -> 100)`
* `@fieldTags(field = myForm("mytags"), 'placeholder -> "Type hashtags")`
* `@fieldText(field = myForm("fieldName"), 'size -> 10, 'placeholder -> "Your name", 'mask -> "9999-99-99", 'tooltip -> "date input mask")`
* `@fieldTextarea(field = myForm("fieldName"), 'placeholder -> "type your story")`
* `@fieldDatepicker(field = myForm("fieldName"))`
* `@helper.formButtons("submit", "cancel")`

Additional template helpers
============================
Helpers to perform role-based security checks of current user within a template:

	@helper.security.restrict(List("registered")) {
		  <p>This content should be visible to registered users only</p<
	}
	
and using role groups:

	@helper.security.restrictAll(List(List("registered"))) {
		  <p>This content should be visible to registered users only</p<
	}


The `paginator` helper provides rendering of pagination. The current page is appended as a query string parameter `?page=X`:

	@paginator(myPager, controllers.Application.myPagedAction)
	
Where `myPager` needs to be an `play.modules.playa.service.Pagination.Paginator` implementation.

Storage subsystem
==================
Playa provides an easy and straight forward way to store, retrive and serve files from GridFS. It also removes the pain from handling file uploads quite a bit !

File Uploads
-------------
Playa provides an extension to Play! forms to remove the pain from receiving uploaded files.

You need to:

* extend your controller from `StorageProvider` trait to get access to the implicit `gfs` property
* define file field as (regular) text field in your form
* use the `gridFSBodyParser(gfs)` body parser in your form submission action
* use the `form.bindFromMultipartRequest()` to validate and bind form data

Let's see an example where we define a form with a text field and two file fields. The `userfile1` for an avatar image which can only be accessed by registered users and `userfile2` for another public accessable file.

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
		    		formWithErrors => Ok(play.ui.backend.views.html.upload("Upload Test", formWithErrors)),
		    		value => {
		    		  request.user match {
		    		    case Some(u) => 
		    		      play.modules.playa.service.UserProvider.update(u.copy(avatarUrl = Some(controllers.routes.StorageController.imageItem(value._2).url)))
		    		    case _ => None
		    		  }
		    		  Redirect(routes.PlayaWelcome.upload)		    		}
		    )}
    }
    
In your template you could use Playa's custom form field helpers:

	@helper.form(action = routes.PlayaWelcome.handleUpload, 'class -> "form-horizontal", 'enctype -> "multipart/form-data") {
    		@helper.fieldText(form("name"), '_label -> "Your name", 'placeholder -> "Give some name", 'tooltip -> "Name of uploaded file")
    		@helper.fieldImage(form("userfile1"), '_label -> "avatar")
    		@helper.fieldImage(form("userfile2"), '_label -> "2nd image")
    		@helper.formButtons()
	}

The form is simply defnied as a tuple of Strings which will contain the storageId (GridFS `_id`) of the uploaded and stored files. The form submission handling is straight forward like you do with every Play! forms. The only difference is the call to `bindFromMultipartRequest` method provided by the Playa form extension and the custom `gridFSBodyParser`

You can optionally assign roles to storage items which are required (and checked!) when accessing the storage item from the built-in `StorageController`. Or, yo can just use `bindFromMultipartRequest()` for public accessable items without assigning any roles.

Note: the sample uses `UserAwareAction` ActionBuilder but you can use the form extensions with with any other Play! action.

Serving storage items with RouterHelper URLs
------------------------------
Playa comes with a `StorageController` implementation to easily serve your stored files / uploads and a RouteHelper to build URLs in your templates by just using the storageId:

to serve an image item:

	@play.modules.playa.RouteHelper.imageItem(storageId)
	
to serve an arbitrary storage item:

	@play.modules.playa.RouteHelper.storageItem(storageId)
	
to serve the file with CONTENT_DISPOSITION inline:

	@play.modules.playa.RouteHelper.storageItem(storageId)?inline=true
	
You can change the route pattern in your `routes.conf`
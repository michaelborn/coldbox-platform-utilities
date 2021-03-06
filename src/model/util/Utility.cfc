<cfcomponent output="false">
<cfscript>

	function getTestBoxReporters(){
		var reporters = [
			"ANTJunit", "CodexWiki", "Console", "Doc", "Dot", "JSON", "JUnit", "Min", "Raw", "Simple", "Tap", "Text", "XML"
		];
		arraySort( reporters, "textnocase" );
		return reporters;
	}

	function entityPropertyToStruct(str){
		var x =1;
		var map = {};
		var propertyList = "";

		arguments.str = REReplaceNoCase(arguments.str,"(cf)?property","");
		arguments.str = REReplaceNoCase(arguments.str," {2,}"," ");

		propertyList = listToArray(arguments.str," ");

		for(x=1; x lte arrayLen(propertyList);x++){
			map[ getToken( propertyList[x], 1, "=") ] = reREplace( getToken( propertyList[x], 2, "="), "'|#chr(34)#","","all");
		}

		// add defaults to it
		if( NOT structKeyExists(map,"fieldType") ){ map.fieldType = "column"; }
		if( NOT structKeyExists(map,"persistent") ){ map.persistent = true; }
		if( NOT structKeyExists(map,"formula") ){ map.formula = ""; }
		if( NOT structKeyExists(map,"readonly") ){ map.readonly = false; }

		// Add column isValid depending if it is persistable
		map.isPersistable = true;
		if( NOT map.persistent OR len(map.formula) OR map.readonly ){
			map.isPersistable = false;
		}

		return map;
	}

	function getInjectionDSLArray(){
		var injectionDSL = [
		"ioc","ocm","model","webservice","coldbox","coldbox:setting:","coldbox:plugin",
		"coldbox:myplugin","coldbox:datasource","coldbox:configBean","coldbox:mailSettingsBean",
		"coldbox:loaderService","coldbox:requestService","coldbox:debuggerService",
		"coldbox:pluginService","coldbox:handlerService","coldbox:moduleService",
		"coldbox:moduleSettings:","coldbox:moduleConfig:","coldbox:flash",
		"coldbox:interceptor","coldbox:cacheManager","coldbox:fwConfigBean","coldbox:fwSetting:",
		"coldbox:validationManager",
		"entityService","javaLoader","logBox","logBox:root","logBox:logger:","id",
		"provider",
		"wirebox","wirebox:parent","wirebox:eventmanager","wirebox:binder","wirebox:populator","wirebox:properties","wirebox:scope:","wirebox:property:",
		"cachebox"
		];
		arraySort(injectionDSL,"textnocase");
		return injectionDSL;
	}

	function capFirstLetter(str){
		return rereplace(lcase(arguments.str), "(\b\w)", "\u\1", "all");
	}

	/**
	* Check for version updates
	* cVersion.hint The current version of the system
	* nVersion.hint The newer version received
	*/
	function isNewVersion( cVersion, nVersion ){
		/**
		Semantic version: major.minor.revision-alpha.1+build
		**/

		var cVersionData 	= parseSemanticVersion( trim( arguments.cVersion ) );
		var nVersionData 	= parseSemanticVersion( trim( arguments.nVersion ) );

		// Major check
		if( nVersionData.major gt cVersionData.major ){
			return true;
		}

		// Minor Check
		if( nVersionData.major eq cVersionData.major AND nVersionData.minor gt cVersionData.minor ){
			return true;
		}

		// Revision Check
		if( nVersionData.major eq cVersionData.major AND
			nVersionData.minor gt cVersionData.minor AND
			nVersionData.revision gt cVersionData.revision ){
			return true;
		}

		// BuildID Check
		if( nVersionData.major eq cVersionData.major AND
			nVersionData.minor gt cVersionData.minor AND
			nVersionData.revision gt cVersionData.revision AND
			nVersionData.buildID gt cVersionData.buildID ){
			return true;
		}

		return false;
	}

	/**
	* Parse the semantic version
	* @return struct:{major,minor,revision,beid,buildid}
	*/
	private struct function parseSemanticVersion( required string version ){
		var results = { major = 1, minor = 0, revision = 0, beID = "", buildID = 0 };

		// Get build ID first
		results.buildID		= find( "+", arguments.version ) ? listLast( arguments.version, "+" ) : '0';
		// REmove build ID
		arguments.version 	= reReplace( arguments.version, "\+([^\+]*).$", "" );
		// Get BE ID Formalized Now we have major.minor.revision-alpha.1
		results.beID		= find( "-", arguments.version ) ? listLast( arguments.version, "-" ) : '';
		// Remove beID
		arguments.version 	= reReplace( arguments.version, "\-([^\-]*).$", "" );
		// Get Revision
		results.revision	= getToken( arguments.version, 3, "." );
		if( results.revision == "" ){ results.revision = 0; }

		// Get Minor + Major
		results.minor		= getToken( arguments.version, 2, "." );
		if( results.minor == "" ){ results.minor = 0; }
		results.major 		= getToken( arguments.version, 1, "." );

		return results;
	}


	function getURLBasePath(){
		var scriptPath = CGI.script_name;
		var javaStrObj = createObject("java", "java.lang.String").init( scriptPath );
		var index = javaStrObj.lastIndexOf( "/" );

		scriptPath = javaStrObj.subString( 0, index );

		return "http://" & CGI.SERVER_NAME & ":" & CGI.SERVER_PORT & scriptPath;
	}
</cfscript>

	<!---
	@author Topper (topper@cftopper.com)
	--->
	<cffunction name="getCurrentURL" output="No" access="public" returnType="string">
		<cfargument name="removeTemplate" type="boolean" required="false" default="false"/>

	    <cfset var theURL = getPageContext().getRequest().GetRequestUrl().toString()>
	    <cfif len( CGI.query_string )><cfset theURL = theURL & "?" & CGI.query_string></cfif>
	    <!--- Hack by Raymond, remove any CFID CFTOKEN --->
		<cfset theUrl = reReplaceNoCase(theUrl, "[&?]*cfid=[0-9]+", "")>
		<cfset theUrl = reReplaceNoCase(theUrl, "[&?]*cftoken=[^&]+", "")>

	    <!--- LM: If currentTemplate --->
		<cfif removeTemplate>
			<cfset theURL = replaceNoCase(theURL, getFileFromPath(theURL), "")>
		</cfif>

	    <cfreturn theURL>
	</cffunction>

	<!--- prettifyXML --->
    <cffunction name="prettifyXML" output="false" access="public" returntype="any" hint="prettify xml">
    	<cfargument name="inXML" type="any" required="true" default="" hint="The xml document to prettify"/>
    	<cfscript>
    		var formatterPath = getDirectoryFromPath(getMetadata(this).path) & "/xmlFormatter.xsl";

    		return xmlTransform(toString(arguments.inXML),FileRead(formatterPath));
    	</cfscript>
    </cffunction>

	<!--- createDirectory --->
    <cffunction name="createDirectory" output="false" access="public" returntype="void" hint="">
    	<cfargument name="path" type="string" required="true" />
    	<cfdirectory action="create" directory="#arguments.path#">
    </cffunction>

	<!---
	@author Joe Rinehart (joe.rinehart@gmail.com)
	--->
	<cffunction name="directoryCopy" output="true" hint="copy a directory" returntype="void">
	    <cfargument name="source" 		required="true" type="string">
	    <cfargument name="destination" 	required="true" type="string">

	    <cfset var contents = "" />

	    <cfif not(directoryExists(arguments.destination))>
	        <cfdirectory action="create" directory="#arguments.destination#">
	    </cfif>

	    <cfdirectory action="list" directory="#arguments.source#" name="contents">

	    <cfloop query="contents">
	        <cfif contents.type eq "file">
	            <cffile action="copy" source="#arguments.source#/#name#" destination="#arguments.destination#/#name#">
	        <cfelseif contents.type eq "dir">
	            <cfset directoryCopy(arguments.source & "/" & name, arguments.destination & "/" & name) />
	        </cfif>
	    </cfloop>
	</cffunction>

	<!--- throw it --->
	<cffunction name="throwit" access="public" hint="Facade for cfthrow" output="false">
		<cfargument name="message" 	required="true">
		<cfargument name="detail" 	required="false" default="">
		<cfargument name="type"  	required="false" default="Framework">
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>

	<!--- rethrowit --->
	<cffunction name="rethrowit" access="public" returntype="void" hint="Rethrow an exception" output="false" >
		<cfargument name="throwObject" required="true" hint="The exception object">
		<cfthrow object="#arguments.throwObject#">
	</cffunction>

	<!--- dump it --->
	<cffunction name="dumpit" access="public" hint="Facade for cfmx dump" returntype="void" output="true">
		<cfargument name="var" 		required="true">
		<cfargument name="isAbort"  type="boolean" default="false" required="false" hint="Abort also"/>
		<cfdump var="#var#"><cfif arguments.isAbort><cfabort></cfif>
	</cffunction>

	<!--- abort it --->
	<cffunction name="abortit" access="public" hint="Facade for cfabort" returntype="void" output="false">
		<cfabort>
	</cffunction>

</cfcomponent>
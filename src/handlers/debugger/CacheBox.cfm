<cfscript>
serverInfo = data.event.ide.projectView.server.XMLAttributes;
rootURL = replaceNoCase( data.event.ide.projectView.resource.xmlAttributes.path, serverInfo.wwwroot ,"" ) & "/index.cfm";
</cfscript>
<cfheader name="Content-Type" value="text/xml">
<cfoutput> 
<response showresponse="true"> 
<ide url="http://#serverInfo.hostName#:#serverInfo.port#/#rootURL#?debugpanel=cache" >
	<view id="cbox_cachebox_monitor" title="ColdBox CacheBox Monitor" icon="includes/images/coldbox_logo.jpg" />
</ide> 
</response> 
</cfoutput>
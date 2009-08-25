<!-----------------------------------------------------------------------
Author 	 :	Sana Ullah
Date     :	August 1, 2009
Description :
---------------------------------------------------------------------->
<!--- set handler properties default values --->
<cfset defaultDescription 	= "I am a new handler" />
<cfset defaultName			= "" />
<cfset message	= "" /> 
<cfset data		= xmlParse(ideeventinfo)>

<cfset extxmlinput = xmlSearch(data, "/event/user/input")>
<cfset inputstruct = StructNew()>

<cfloop index="i" from="1" to="#arrayLen(extxmlinput)#" >
	<cfset StructInsert(inputstruct,"#extxmlinput[i].xmlAttributes.name#","#extxmlinput[i].xmlAttributes.value#")>
</cfloop>

<!--- ======================================================================= --->
<cfif not len(inputstruct.Name)>
	<cfset message = "The handler name cannot be empty" />
	<cfheader name="Content-Type" value="text/xml">  
	<response status="success" showresponse="true">  
		<ide>  
			<dialog width="550" height="350" />  
			<body>
			<![CDATA[<p style="font-size:12px;"><cfoutput>#message#</cfoutput></p>]]>
			</body>
		</ide>
	</response>
	
	<cfabort>
</cfif>
<!--- ======================================================================= --->

<!--- Expand Locations --->
<cfset expandLocation	= data.event.ide.projectview.resource.xmlAttributes.path />
<cfset handlerName		= inputstruct.Name />
<cfset scriptPrefix = "">
<!--- Script? --->
<cfif inputStruct.Script>
	<cfset scriptPrefix = "Script">
</cfif>

<!--- Read in Template --->
<cffile action="read" file="#ExpandPath('../')#/templates/HandlerContent#scriptPrefix#.txt" variable="handlerContent">
<cffile action="read" file="#ExpandPath('../')#/templates/ActionContent#scriptPrefix#.txt"  variable="actionContent">


<!--- Start Replacings --->
<cfset handlerContent = replaceNoCase(handlerContent,"|Name|",inputstruct.Name,"all") />

<cfif len(inputstruct.Description)>
	<cfset handlerContent = replaceNoCase(handlerContent,"|Description|",inputstruct.Description,"all") />
<cfelse>
	<cfset handlerContent = replaceNoCase(handlerContent,"|Description|",defaultDescription,"all") />	
</cfif>

<!--- Handle Actions if passed --->
<cfif len(inputstruct.Actions)>
	<cfset allActions = "">
	<cfloop list="#inputStruct.Actions#" index="thisAction">
		<cfset allActions = allActions & replaceNoCase(actionContent,"|action|",thisAction,"all") & chr(13) & chr(13)/>
	</cfloop>
	<!--- Replace Handler Name in all actions --->
	<cfset allActions = replaceNoCase(allActions,"|name|",inputStruct.Name,"all") />
	<cfset handlerContent = replaceNoCase(handlerContent,"|EventActions|",allActions,"all") />	
<cfelse>
	<cfset handlerContent = replaceNoCase(handlerContent,"|EventActions|",'',"all") />	
</cfif>

<!--- Write it out. --->
<cftry>
	<cffile action="write" file="#expandLocation#/#handlerName#.cfc" mode ="777" output="#handlerContent#">
	<cfset message = handlerName & ".cfc Generated new handler" />
<cfcatch type="any">
	<cfset message = "There was problem creating handler: #cfcatch.message#" />
</cfcatch>
</cftry>

<cfheader name="Content-Type" value="text/xml">  
<response status="success" showresponse="true">  
<ide>  
	<dialog width="550" height="350" title="ColdBox Event Handler Wizard" image="images/ColdBox_Icon.png"/>  
	<body><![CDATA[<p style="font-size:12px;"><cfoutput>#message#</cfoutput></p>]]></body>
</ide>
</response>


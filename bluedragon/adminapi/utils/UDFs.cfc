<!---
	Copyright (C) 2008 - Open BlueDragon Project - http://www.openbluedragon.org
	
	Contributing Developers:
	David C. Epler - dcepler@dcepler.net
	Matt Woodward - matt@mattwoodward.com

	This file is part of the Open BlueDragon Admin API.

	The Open BlueDragon Admin API is free software: you can redistribute 
	it and/or modify it under the terms of the GNU General Public License 
	as published by the Free Software Foundation, either version 3 of the 
	License, or (at your option) any later version.

	The Open BlueDragon Admin API is distributed in the hope that it will 
	be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
	of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
	General Public License for more details.
	
	You should have received a copy of the GNU General Public License 
	along with the Open BlueDragon Admin API.  If not, see 
	<http://www.gnu.org/licenses/>.
--->
<cfcomponent displayname="UDFs"
		output="false" 
		hint="UDFs for OpenBD admin console">

	<!--- 
		sortArrayOfObjects courtesy of Martijn van der Woud: http://tinyurl.com/4cxtue
		Used with permission.
	--->
	<cffunction name="sortArrayOfObjects"
				access="public"
				output="false"
				returntype="Array"
				hint="Returns an array of object sorted on one or more specified keys.
					Sort order can be specified seperately per key.
					Objects to be sorted can be either arrays or instantiated cfc's">
	
		<cfargument name="arrayToSort"
					type="Array"
					required="true"
					hint="An array that contains the objects to be sorted">
	
		<cfargument name="sortKeys"
					type="Array"
					required="true"
					hint="An array of structures with sorting specifications.
						Each struct in the array represents a key to sort the objects on.
						Each struct must have the following keys:
							1)'keyname' - string - the name of the property to sort the objects by
							2)'sortOrder' - string -the order in which to sort.
								Must be set to either 'ascending' or 'descending'">
	
		<cfargument name="doDuplicate"
					default="false"
					type="Boolean"
					required="false"
					hint="By default, the objects in the returned array point to the same memory location
						as the objects in the argument 'arrayToSort'.
						After executing this function changing an object in the returned array
						thus also changes the corresponding object in the argument array, and vice versa!
						If this kind of behavior is unwanted, specify this argument as true.">
	
		<cfargument name="useGetterMethods" 
					default="false" 
					type="Boolean" 
					required="false" 
					hint="This function is able to sort either structures or instantiated objects.
						If you are sorting structures, or if the properties you are sorting on are
						in the THIS scope of your instantiated cfcs, leave this to false.
						If you are sorting instantiated cfcs on private properties set this to true. 
						In the latter case this function will try to access the properties
						by calling the method get<propertyname>() on the objects ">
	
			<!--- a struct to hold variables local to this function --->
			<cfset var locals = structNew()>
			
			<!--- the array to be returned by this function (now empty) --->
			<cfset locals.arrayToReturn = arrayNew(1)>
	
			<!--- the number of elements in the array that was passed in --->
			<cfset locals.nElements = arrayLen(arguments.arrayToSort)>
			
			<!--- the number of keys on which sorting is to take place --->
			<cfset locals.nSortKeys = arrayLen(arguments.sortKeys)>
								  
			<!--- for every element in the array that was passed in --->
			<cfloop from="1" to="#locals.nElements#" index="locals.i">
				<!--- reference to the data in the current element in 'arrayToSort' --->
				
				<cfset locals.elementData = arguments.arrayToSort[locals.i]>			
	
				<!--- purpose of the code below is to determine on what position the 
				current element is to be put on the array to be returned
				the position is initialized as 1 --->
				<cfset locals.insertPosition = 1>
	
				<!--- for every element that has been previously put in the array to return --->
				<cfset locals.nPreviousElements = locals.i - 1>
				<cfloop from="1" to="#locals.nPreviousElements#" index="locals.j">
					
					<!--- reference to the current element in the array to return --->
					<cfset locals.previousElementData = locals.arrayToReturn[locals.j]>
	
					<!--- boolean used in the loop over sortkeys, to indicate that the loop over
					elements in the array to return must be broken out of. --->
					<cfset locals.doBreak = false>
	
					<!--- for every sortkey --->
					<cfloop from="1" to="#locals.nSortKeys#" index="locals.k">
	
						<!--- specifications for the current key --->
						<cfset locals.currentKey = arguments.sortKeys[locals.k]>
						
	
						<!--- When specified, use getter methods to access values --->
						<cfif arguments.useGetterMethods>
							<cfset locals.methodName = "get" & locals.currentKey.keyName>
	
							<!--- Value of the current key in the current element in 'arrayToSort'--->
						 	<cfinvoke component="#locals.elementData#" 
										returnvariable="locals.currentValue" 
										method="#locals.methodName#">						
							
							<!--- value of the current key in the current element in 'arrayToReturn' --->
							<cfinvoke component="#locals.previousElementData#"
										returnvariable="locals.previousValue"
										method="#locals.methodName#">
										
						<!--- Otherwise, access values via public keys --->		
						<cfelse>
						
							<!--- Value of the current key in the current element in 'arrayToSort'--->						
							<cfset locals.currentValue = locals.elementData[locals.currentKey.keyName]>
							<!--- value of the current key in the current element in 'arrayToReturn' --->			
							<cfset locals.previousValue = locals.previousElementData[locals.currentKey.keyName]>
	
						</cfif>
	
						
						<!--- boolean indicating if the key-value of the current element in the passed-in array
						is greater than the key-value in the current element, 
						previously inserted in the array to return --->
						<cfset locals.currentGreater = locals.currentValue gt locals.previousValue>
						<!--- boolean indicating if the key-value in the array to return is greater --->
						<cfset locals.previousGreater = locals.previousValue gt locals.currentValue>					
	
						<!--- boolean indicating if the current element in the array to sort must go 
						BEFORE the previously inserted element in the array to return --->
						<cfset locals.currentFirst = 
							(locals.currentGreater AND (locals.currentKey.sortOrder eq "descending"))
							OR (locals.previousGreater AND (locals.currentKey.sortOrder eq "ascending"))>
					
						
						<!--- boolean indication if the current element in the array to sort must go 
						AFTER the previously inserted element in the array to return --->
						<cfset locals.previousFirst = 
							(locals.previousGreater AND (locals.currentKey.sortOrder eq "descending"))
							OR (locals.currentGreater AND (locals.currentKey.sortOrder eq "ascending"))>
	
						
						<!--- If the element previously inserted in the array to return goes first --->
						<cfif locals.previousFirst>
							<!--- Increment the insertPosition of the current element in arrayToSort by one --->
							<cfset locals.insertPosition = locals.insertPosition + 1>
							<!--- Break out of the loop over sortkeys --->
							<cfbreak>			
						</cfif>
	
						<!--- if the current element in the array to sort goes first ---> 	
						<cfif locals.currentFirst>
							<!--- Indicate that the loop over element in arrayToReturn must be broken out of --->
							<cfset locals.doBreak = true>
							<!--- Break out of the loop over sortKeys --->
							<cfbreak>
						</cfif>
	
					</cfloop><!--- End of loop over sortKeys --->
					
					<!--- When indicated from inside the inner loop, 
						break out of the loop over elements in arrayToReturn --->
					<cfif locals.doBreak>
						<cfbreak>
					</cfif>
	
				</cfloop><!--- End of loop over elements in arrayToReturn --->
	
				<!--- at this point locals.insertPosition holds the correct position, where the current 
				element in the array to sort (argument) should be put --->
				
				<!--- based on the value of the 'doDuplicate' argument, get either a deep copy or a reference of the 
				data to insert in the array to return --->
				<cfif arguments.doDuplicate>
					<cfset locals.insertData = duplicate(locals.elementData)>
				<cfelse>
					<cfset locals.insertData = locals.elementData>
				</cfif>
				
				<!--- if the insertposition is not greater than the current length of the array to return --->
				<cfif locals.insertPosition lt locals.i>
					<!--- do an insert into the correct position --->
					<cfset arrayInsertAt(locals.arrayToReturn, locals.insertPosition, locals.insertData)>
				<cfelse>
					<!--- Otherwise, do an append --->	
					<cfset arrayAppend(locals.arrayToReturn, locals.insertData)>	
				</cfif>
	
			</cfloop><!--- End of loop over elements in arrayToSort --->
			
			<!--- Return the sorted array --->
			<cfreturn locals.arrayToReturn>
	</cffunction>
</cfcomponent>

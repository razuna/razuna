<<!--
Copyright 2006-07 Objective Internet Ltd - http://www.objectiveinternet.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->>
	<fuseaction name="ReInitialise" access="internal">
		<!-- I check the URL parameters for the init variable if present all the cached objects are recreated -->
		<if condition="isDefined('attributes.init')">
			<true>
				<do action="Initialise" />
			</true>
		</if>
	</fuseaction>

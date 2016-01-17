<cfcomponent output="false">

<!---
 *  Copyright (C) 2000 - 2011 TagServlet Ltd
 *
 *  This file is part of Open BlueDragon (OpenBD) CFML Server Engine.
 *
 *  OpenBD is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  Free Software Foundation,version 3.
 *
 *  OpenBD is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with OpenBD.  If not, see http://www.gnu.org/licenses/
 *
 *  Additional permission under GNU GPL version 3 section 7
 *
 *  If you modify this Program, or any covered work, by linking or combining
 *  it with any of the JARS listed in the README.txt (or a modified version of
 *  (that library), containing parts covered by the terms of that JAR, the
 *  licensors of this Program grant you additional permission to convey the
 *  resulting work.
 *  README.txt @ http://www.openbluedragon.org/license/README.txt
 *
 *  http://www.openbluedragon.org/
 *
 * 	$Id: mongo.cfc 1760 2011-11-03 16:34:55Z simon $
	--->

<cfscript language="java" jarlist="mongo-2.6.5.jar" import="com.mongodb.*,org.bson.types.*">
private Mongo mongo = null;
private HashMap<String, DB>	dbFactory = new HashMap<String, DB>();


/**
 * Setup the connection to Mongo
 */
public void create( String host ) throws Exception {
	createWithPort( host, 27017 );
}



public void createWithPort( String host, int port ) throws Exception {
	mongo = new Mongo( host, port );
}


private synchronized DB getDatabase( String dbname ){
	if ( dbFactory.containsKey(dbname) ){
		return dbFactory.get(dbname);
	}else{
		DB	db = mongo.getDB( dbname );
		dbFactory.put( dbname, db );
		return db;
	}
}



/**
 * Drops the Collection from the database
 */
public void dropCollection( String dbname, String collection ) throws Exception {
	getDatabase(dbname).getCollection(collection).drop();
}


/**
 * Lists all the databases in mongo
 */
public List getDatabaseNames(){
	List all = mongo.getDatabaseNames();
	return all;
}


/**
 * Close this connection
 */
public void close(){
	try{
		mongo.close();
	}catch(Exception e){}

}



/**
 * Runs any specific command directly to the mongo database
 */
public Map	runCommand( String dbname, String cmd ) throws Exception {
	return getDatabase(dbname).command( cmd ).toMap();
}



/**
 * Counts the number of documents in a given collection within the current database
 */
public long	getDocumentsCount(String dbname, String collection) throws Exception {
	return getDatabase(dbname).getCollection(collection).getCount();
}



/**
 * Creates an index on the collection
 */
public void createIndex(String dbname, String collection, Map map) throws Exception {
	DBCollection col = getDatabase(dbname).getCollection(collection);
	BasicDBObject document = convertToDBObject( new BasicDBObject(), map );
	col.createIndex( document );
}



/**
 * Drops the indexes on the collection
 */
public void	dropIndexes(String dbname, String collection) throws Exception {
	getDatabase(dbname).getCollection(collection).dropIndexes();
}



/**
 * Performs a count on the collection, using the optional query
 * if @query is null or empty, then it returns the count of the total documents
 */
public long count( String dbname, String collection, Map query ){
	DBCollection col = getDatabase(dbname).getCollection(collection);
	if ( query == null || query.size() == 0 )
		return col.count();
	else
		return col.count( convertToDBObject( new BasicDBObject(), query ) );
}



/**
 * Gets a specific document
 */
public Map getDocument(String dbname, String collection, String _id) throws Exception {
	DBCollection col = getDatabase(dbname).getCollection(collection);

	BasicDBObject k = new BasicDBObject();
	k.put( "_id", new ObjectId(_id) );

	Map m	= col.findOne( k ).toMap();
	if ( m.containsKey("_id"))
		m.put( "_id", m.get("_id").toString() );

	return m;
}



/**
 * Find records, and updates the fields accordingly, creating new records if they do not exist
 */
public void upsert( String dbname, String collection, Map query, Map update ) throws Exception {
	DBCollection col = getDatabase(dbname).getCollection(collection);
	BasicDBObject queryObj = convertToDBObject( new BasicDBObject(), query );
	BasicDBObject updateObj = convertToDBObject( new BasicDBObject(), update );

	col.update( queryObj, updateObj, true, true );
}



/**
 * Find records, and updates the fields accordingly
 */
public void update( String dbname, String collection, Map query, Map update ) throws Exception {
	DBCollection col = getDatabase(dbname).getCollection(collection);
	BasicDBObject queryObj = convertToDBObject( new BasicDBObject(), query );
	BasicDBObject updateObj = convertToDBObject( new BasicDBObject(), update );

	col.update( queryObj, updateObj, false, true );
}



/**
 * Find records, and returns all the fields associated with a record
 */
public List find( String dbname, String collection, Map query, int skip, int size ){
	return findReturnFields( dbname, collection, query, null, skip, size );
}


/**
 * Find records, and returns the fields given
 */
public List findReturnFieldsSorted( String dbname, String collection, Map query, Map fields, Map sort, int skip, int size ){
	List<Map<String,Object>>	results = new ArrayList<Map<String,Object>>(size);

	DBCollection col = getDatabase(dbname).getCollection(collection);
	BasicDBObject queryObj = convertToDBObject( new BasicDBObject(), query );

	BasicDBObject fieldsQ;
	if ( fields != null && fields.size() > 0 )
		fieldsQ = convertToDBObject( new BasicDBObject(), fields );
	else
		fieldsQ = new BasicDBObject();

	BasicDBObject sortQ;
	if ( sort != null && sort.size() > 0 )
		sortQ = convertToDBObject( new BasicDBObject(), sort );
	else
		sortQ = new BasicDBObject();

	DBCursor mongoQuery = col.find(queryObj, fieldsQ, skip, size).sort(sortQ).limit(size);
	DBObject dbrecord = null;
	while (mongoQuery.hasNext()) {
		dbrecord = mongoQuery.next();

		Map m	= dbrecord.toMap();
		m.put( "_id", m.get("_id").toString() );

		results.add( m );
	}

	return results;
}



/**
 * Find records, and returns the fields given
 */
public List findReturnFields( String dbname, String collection, Map query, Map fields, int skip, int size ){
	List<Map<String,Object>>	results = new ArrayList<Map<String,Object>>(size);

	DBCollection col = getDatabase(dbname).getCollection(collection);
	BasicDBObject queryObj = convertToDBObject( new BasicDBObject(), query );

	BasicDBObject fieldsQ;
	if ( fields != null && fields.size() > 0 )
		fieldsQ = convertToDBObject( new BasicDBObject(), fields );
	else
		fieldsQ = new BasicDBObject();

	DBCursor mongoQuery = col.find(queryObj, fieldsQ, skip, size).limit(size);
	DBObject dbrecord = null;
	while (mongoQuery.hasNext()) {
		dbrecord = mongoQuery.next();

		Map m	= dbrecord.toMap();
		m.put( "_id", m.get("_id").toString() );

		results.add( m );
	}

	return results;
}



/**
 * Insert a new document into the given collection
 */
public void deleteDocument(String dbname, String collection, String _id) throws Exception {
	DBCollection col = getDatabase(dbname).getCollection(collection);

	BasicDBObject k = new BasicDBObject();
	k.put( "_id", new ObjectId(_id) );
	col.remove( k );
}



/**
 * Insert a new document into the given collection
 */
public String insert(String dbname, String collection, Map map) throws Exception {
	DBCollection col = getDatabase(dbname).getCollection(collection);

	BasicDBObject document = convertToDBObject( new BasicDBObject(), map );

	WriteResult wr = col.insert( document );
	return ((ObjectId)document.get("_id")).toString();
}



/**
 * Converts the java object into a BasicDBObject; recursive
 */
private BasicDBObject	convertToDBObject(BasicDBObject document, Map map){
	Iterator<String> it = map.keySet().iterator();
	while ( it.hasNext() ){
		String key = it.next();
		Object o = map.get(key);

		if ( o instanceof Map ){
			document.put( key, convertToDBObject( new BasicDBObject(), (Map)o ) );
		}else{
			document.put( key, o );
		}
	}
	return document;
}
</cfscript>


</cfcomponent>
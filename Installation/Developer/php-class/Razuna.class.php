<?php

/*
 *
 * Copyright (C) 2005-2008 Razuna Ltd.
 *
 * This file is part of Razuna - Enterprise Digital Asset Management.
 *
 * Razuna is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Razuna is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero Public License for more details.
 *
 * You should have received a copy of the GNU Affero Public License
 * along with Razuna. If not, see <http://www.gnu.org/licenses/>.
 *
 * You may restribute this Program with a special exception to the terms
 * and conditions of version 3.0 of the AGPL as described in Razuna's
 * FLOSS exception. You should have received a copy of the FLOSS exception
 * along with Razuna. If not, see <http://www.razuna.com/licenses/>.
 *
 *
 * HISTORY:
 * Date US Format		User					Note
 * 2009/11/01			SÃ©bastien Massiaux		Initial Library
 * 2010/01/16			Christof Dorner			Refactored Library
 * 2011/01/19			Nitai Aventaggiato		Updated IDs to string for 1.4.2
 * 2011/06/27			Darcy W. Christ 		Added getAssetByID, refactored 					
 												RazunaAsset object for ease of use and complete data returned by API
 *

 */

class Razuna {
    const AUTH_URI = '/global/api/authentication.cfc?wsdl';
    const FOLDER_URI = '/global/api/folder.cfc?wsdl';
    const COLLECTION_URI = '/global/api/collection.cfc?wsdl';
    const HOSTS_URI = '/global/api/hosts.cfc?wsdl';
    const SEARCH_URI = '/global/api/search.cfc?wsdl';
    const USER_URI = '/global/api/user.cfc?wsdl';
    const ASSET_URI = '/global/api/asset.cfc?wsdl';

    const HOST_TYPE_ID = 1;
    const HOST_TYPE_NAME = 2;

    const ASSET_TYPE_ALL = 'all';
    const ASSET_TYPE_IMAGE = 'img';
    const ASSET_TYPE_VIDEO = 'vid';
    const ASSET_TYPE_DOCUMENT = 'doc';
    const ASSET_TYPE_AUDIO = 'aud';

    const DOC_TYPE_EMPTY = 'empty';
    const DOC_TYPE_PDF = 'pdf';
    const DOC_TYPE_EXCEL = 'xls';
    const DOC_TYPE_WORD = 'doc';
    const DOC_TYPE_OTHER = 'other';

    private $soap_authentication;
    private $soap_folder;
    private $soap_collection;
    private $soap_search;
    private $soap_upload;
    private $soap_hosts;
    private $soap_user;
    private $soap_asset;
    private $config_host;
    private $config_hostid;
    private $config_username;
    private $config_password;
    private $config_passhashed;
    private $config_host_type;
    private $session_token;

    function __construct() {
        $argv = func_get_args();
        switch (func_num_args()) {
            default:
            case 5:
                self::__construct1($argv[0], $argv[1], $argv[2], $argv[3], $argv[4]);
                break;
            case 6:
                self::__construct2($argv[0], $argv[1], $argv[2], $argv[3], $argv[4], $argv[5]);
                break;
        }
    }

    function __construct1($host, $username, $password, $passhashed, $host_type = self::HOST_TYPE_NAME) {
        $this->config_host = $host;
        $this->config_username = $username;
        $this->config_password = $password;
        $this->config_passhashed = ($passhashed == true) ? 1 : 0;
        $this->config_host_type = $host_type;
    }

    function __construct2($hostid, $host, $username, $password, $passhashed, $host_type = self::HOST_TYPE_NAME) {
        $this->config_hostid = $hostid;
        $this->config_host = $host;
        $this->config_username = $username;
        $this->config_password = $password;
        $this->config_passhashed = ($passhashed == true) ? 1 : 0;
        $this->config_host_type = $host_type;
    }

    /*     * ***********************
     *     AUTHENTICATION     *
     * ************************* */

    private function initAuthentication() {
        if (!is_object($this->soap_authentication)) {
            $this->soap_authentication = $this->buildSoapClient(self::AUTH_URI);
        }
    }

    public function login() {
        $this->initAuthentication();

        if ($this->config_host_type == self::HOST_TYPE_ID) {
            $response = $this->soap_authentication->login($this->config_hostid, $this->config_username, $this->config_password, $this->config_passhashed);
        } else {
            $response = $this->soap_authentication->loginhost($this->config_host, $this->config_username, $this->config_password, $this->config_passhashed);
        }
        $xml_result = simplexml_load_string($response);
        if ($xml_result->responsecode == 0) {
            $this->session_token = (string) $xml_result->sessiontoken;
        } else {
            throw new RazunaAccessDeniedException();
        }
        return $this->getSessionToken();
    }

    /*     * ***********************
     *       USER               *
     * ************************* */

    private function initUser() {
        if (!is_object($this->soap_user)) {
            $this->soap_user = $this->buildSoapClient(self::USER_URI);
        }
    }

    public function getSessionUser($session_token = null) {
        $this->initUser();

        if ($session_token == null)
            $session_token = $this->session_token;

        $response = $this->soap_user->getuser($session_token);
        $xml_result = simplexml_load_string($response);
        if ($this->is_session_timed_out($xml_result)) {
            $this->login();
            $this->getSessionuser($session_token);
        }

        $user = new RazunaUser((string) $xml_result->userid, (string) $xml_result->loginname, (string) $xml_result->email, (string) $xml_result->firstname, (string) $xml_result->lastname);
        return $user;
    }

    public function addUser($user, $session_token = null) {
        $this->initUser();

        if ($session_token == null)
            $session_token = $this->session_token;

        $response = $this->soap_user->add($session_token, $user->getFirstName(), $user->getLastName(), $user->getEmail(), $user->getLoginname(), $user->getPassword(), $user->getActive(), 0);
        $xml_result = simplexml_load_string($response);
        if ($this->is_session_timed_out($xml_result)) {
            $this->login();
            $this->addUser($user, $session_token);
        }

        if ($xml_result->responsecode == 1)
            throw new RazunaException($xml_result->message);
        return true;
    }

    /*     * ***********************
     *          FOLDER        *
     * ************************* */

    private function initFolder() {
        if (!is_object($this->soap_folder)) {
            $this->soap_folder = $this->buildSoapClient(self::FOLDER_URI);
        }
    }

    public function getFolders($folderid = 0, $session_token = null) {
        $this->initFolder();

        if ($session_token == null)
            $session_token = $this->session_token;

        $response = $this->soap_folder->getfolders($session_token, $folderid, 0);
        $xml_result = simplexml_load_string($response);
        if ($this->is_session_timed_out($xml_result)) {
            $this->login();
            $this->getFolders($folderid, $session_token);
        }

        if ($xml_result->responsecode == 1)
            throw new RazunaException($xml_result->message);

        $folders = array();
        foreach ($xml_result->listfolders->folder as $xml_folder) {
            $folder = new RazunaFolder((string) $xml_folder->folderid, (string) $xml_folder->foldername, (boolean) $xml_folder->hassubfolder, (int) $xml_folder->totalassets, (int) $xml_folder->totalimg, (int) $xml_folder->totalvid, (int) $xml_folder->totaldoc, (int) $xml_folder->totalaud, (string) $xml_folder->folderowner);
            if ($folder->id != $folderid)
                $folders[] = $folder;
        }

        return $folders;
    }

    public function getRootFolders($userid = null, $session_token = null) {
        $this->initFolder();

        if ($session_token == null)
            $session_token = $this->session_token;

        if ($userid == null)
            $userid = $this->getSessionUser($session_token)->getId();

        $folders = $this->getFolders(0, $session_token);

        $folders_owner = array();
        foreach ($folders as $folder) {
            if ($folder->owner == $userid) {
                $folders_owner[] = $folder;
            }
        }
        return $folders_owner;
    }

    public function getFoldersTree($session_token = null) {
        $this->initFolder();

        if ($session_token == null)
            $session_token = $this->session_token;

        $response = $this->soap_folder->getfolderstree($session_token, 0);
        $xml_result = simplexml_load_string($response);
        if ($this->is_session_timed_out($xml_result)) {
            $this->login();
            $this->getFoldersTree($session_token);
        }

        if ($xml_result->responsecode == 1)
            throw new RazunaException($xml_result->message);

        $folders = array();
        foreach ($xml_result->listfolders->folder as $xml_folder) {
            $folders[] = $this->parseFoldersTreeFolder($xml_folder);
        }
        return $folders;
    }

    private function parseFoldersTreeFolder($xml_folder) {
        $folder = new RazunaFolder((string) $xml_folder->folderid, (string) $xml_folder->foldername, ((string) $xml_folder->hassubfolder == 'true'), (int) $xml_folder->totalassets, (int) $xml_folder->totalimg, (int) $xml_folder->totalvid, (int) $xml_folder->totaldoc, (int) $xml_folder->totalaud, (string) $xml_folder->folderowner, (int) $xml_folder->folderlevel, (string) $xml_folder->parentid);
        if ($folder->has_subfolders) {
            $subfolders = $this->parseFoldersTreeSubfolders($xml_folder);
            $folder->addAllSubfolders($subfolders);
        }
        return $folder;
    }

    private function parseFoldersTreeSubfolders($parent) {
        $folders = array();
        if (count($parent->subfolder) > 0) {
            foreach ($parent->subfolder as $xml_folder) {
                $folders[] = $this->parseFoldersTreeFolder($xml_folder);
            }
        } else {
            $folders = array($this->parseFoldersTreeFolder($parent->subfolder));
        }
        return $folders;
    }

    public function getFoldersTreeFlat($session_token = null) {
        if ($session_token == null)
            $session_token = $this->session_token;

        $folders = $this->getFoldersTree($session_token);
        $folders_arr = array();
        if (count($folders) > 0) {
            foreach ($folders as $folder) {
                $folders_arr[] = $folder;
                $subfolders = $this->getFoldersTreeFlatSubfolders($folder);
                foreach ($subfolders as $subfolder) {
                    $folders_arr[] = $subfolder;
                }
            }
        }
        return $folders_arr;
    }

    private function getFoldersTreeFlatSubfolders($folder) {
        $folders_arr = array();

        if ($folder->has_subfolders) {
            foreach ($folder->subfolders as $subfolder) {
                $folders_arr[] = $subfolder;
                $sub_subfolders = $this->getFoldersTreeFlatSubfolders($subfolder);
                foreach ($sub_subfolders as $sub_subfolder) {
                    $folders_arr[] = $sub_subfolder;
                }
            }
        }
        return $folders_arr;
    }

    public function getAssets($folderid, $session_token = null, $show_subfolders = 0, $offset = 0, $maxrows = 0, $show = self::ASSET_TYPE_ALL) {
        $this->initFolder();

        if ($session_token == null)
            $session_token = $this->session_token;

        $response = $this->soap_folder->getassets($session_token, $folderid, $show_subfolders, $offset, $maxrows, $show);
        $xml_result = simplexml_load_string($response);
        if ($this->is_session_timed_out($xml_result)) {
            $this->login();
            $this->getAssets($folderid, $session_token, $show_subfolders, $offset, $maxrows, $show);
        }

        if ($xml_result->responsecode == 1 && $xml_result->message != '')
            throw new RazunaException($xml_result->message);

        $assets = array();
        //print $response;
        if ($xml_result->responsecode == 0) {
            foreach ($xml_result->listassets->asset as $xml_asset) {
                print_f($xml_result->listassets->asset);
                $asset = new RazunaAsset($xml_asset);
                $assets[] = $asset;
            }
        }
        return $assets;
    }

    /*     * ***********************
     *          ASSET         *
     * ************************* */

    private function initAsset() {
        if (!is_object($this->soap_asset)) {
            $this->soap_asset = $this->buildSoapClient(self::ASSET_URI);
        }
    }

    public function setAssetShared($asset_id, $asset_type, $activate, $session_token = null) {
        $this->initAsset();

        if ($session_token == null)
            $session_token = $this->session_token;

        $response = $this->soap_asset->setshared($session_token, $asset_id, $asset_type, $activate);
        $xml_result = simplexml_load_string($response);
        if ($this->is_session_timed_out($xml_result)) {
            $this->login();
            $this->setAssetShared($asset_id, $asset_type, $activate, $session_token);
        }

        if ($xml_result->responsecode == 1)
            throw new RazunaException($xml_result->message);

        return true;
    }

    public function getAsset($asset_id, $folderid, $session_token = null) {
        if ($session_token == null)
            $session_token = $this->session_token;

        $assets = $this->getAssets($folderid, $session_token);
        if (count($assets) > 0) {
            foreach ($assets as $asset) {
                if ($asset->id == $asset_id)
                    return $asset;
            }
        }

        return null;
    }

    public function getAssetById($asset_id, $asset_type = 'img', $session_token = null) {
        $this->initAsset();

        if ($session_token == null)
            $session_token = $this->session_token;
        
        $response = $this->soap_asset->getasset($session_token, $asset_id, $asset_type);
        $xml_result = simplexml_load_string($response);
        if ($this->is_session_timed_out($xml_result)) {
            $this->login();
            $this->getAssetById($asset_id, $asset_type, $session_token);
        }

        if ($xml_result->responsecode == 1 && $xml_result->message != '')
            throw new RazunaException($xml_result->message);

        $assets = array();
        if ($xml_result->responsecode == 0) {
            foreach ($xml_result->listassets->asset as $xml_asset) {
                return new RazunaAsset($xml_asset);
            }
        }
    }

    /*     * ***********************
     *          HOSTS         *
     * ************************* */

    private function initHosts() {
        if (!is_object($this->soap_hosts)) {
            $this->soap_hosts = $this->buildSoapClient(self::HOSTS_URI);
        }
    }

    public function getHosts($session_token = null) {
        $this->initHosts();

        if ($session_token == null)
            $session_token = $this->session_token;

        $response = $this->soap_hosts->gethosts($session_token);
        $xml_result = simplexml_load_string($response);
        if ($this->is_session_timed_out($xml_result)) {
            $this->login();
            $this->getHosts($session_token);
        }

        if ($xml_result->responsecode == 1 && $xml_result->message != '')
            throw new RazunaException($xml_result->message);

        $hosts = array();
        if ($xml_result->responsecode == 0) {
            foreach ($xml_result->host as $xml_host) {
                $host = new RazunaHost((int) $xml_host->id, (string) $xml_host->name, (string) $xml_host->path, (string) $xml_host->prefix);
                $hosts[] = $host;
            }
        }
        return $hosts;
    }

    /*     * ***********************
     *         SEARCH         *
     * ************************* */

    private function initSearch() {
        if (!is_object($this->soap_search)) {
            $this->soap_search = $this->buildSoapClient(self::SEARCH_URI);
        }
    }

    public function searchAssets($searchfor, $session_token = null, $offset = 0, $maxrows = 0, $show = self::ASSET_TYPE_ALL, $doctype = self::DOC_TYPE_EMPTY) {
        $this->initSearch();

        if ($session_token == null)
            $session_token = $this->session_token;

        $response = $this->soap_search->searchassets($session_token, $searchfor, $offset, $maxrows, $show, $doctype);
        //print_r($response);exit;
        $xml_result = simplexml_load_string($response);
        if ($this->is_session_timed_out($xml_result)) {
            $this->login();
            $this->searchAssets($searchfor, $session_token, $offset, $maxrows, $show, $doctype);
        }

        if ($xml_result->responsecode == 1 && $xml_result->message != '')
            throw new RazunaException($xml_result->message);

        $assets = array();
        if ($xml_result->responsecode == 0) {
            foreach ($xml_result->listassets->asset as $xml_asset) {
                $asset = new RazunaAsset($xml_asset);
                $assets[] = $asset;
            }
        }
        return $assets;
    }

    /*     * ***********************
     *       COLLECTION       *
     * ************************* */

    private function initCollection() {
        if (!is_object($this->soap_collection)) {
            $this->soap_collection = $this->buildSoapClient(self::COLLECTION_URI);
        }
    }

    public function getCollectionsTree($session_token = null) {
        $this->initCollection();

        if ($session_token == null)
            $session_token = $this->session_token;

        $response = $this->soap_collection->getcollectionstree($session_token, 0);
        $xml_result = simplexml_load_string($response);
        if ($this->is_session_timed_out($xml_result)) {
            $this->login();
            $this->getCollectionsTree($session_token);
        }

        if ($xml_result->responsecode == 1 && $xml_result->message != '')
            throw new RazunaException($xml_result->message);

        $folders = array();
        if ($xml_result->responsecode == 0) {
            foreach ($xml_result->listcollections->collection as $xml_collection) {
                $folders[] = $this->parseCollectionsTreeFolder($xml_collection);
            }
        }
        return $folders;
    }

    private function parseCollectionsTreeFolder($xml_collection) {
        $folder = new RazunaFolder((string) $xml_collection->collectionid, (string) $xml_collection->collectionname, ((string) $xml_collection->hassubcollection == 'true'), (string) $xml_collection->collectionowner, (int) $xml_collection->collectionlevel, (string) $xml_collection->parentid);
        if ($folder->has_subfolders) {
            $subfolders = $this->parseCollectionsTreeSubfolders($xml_collection);
            $folder->addAllSubfolders($subfolders);
        }
        return $folder;
    }

    private function parseCollectionsTreeSubfolders($parent) {
        $folders = array();
        if (count($parent->subcollection) > 0) {
            foreach ($parent->subcollection as $xml_collection) {
                $folders[] = $this->parseCollectionsTreeFolder($xml_collection);
            }
        } else {
            $folders = array($this->parseCollectionsTreeFolder($parent->subcollection));
        }
        return $folders;
    }

    public function getCollectionsTreeFlat($session_token = null) {
        if ($session_token == null)
            $session_token = $this->session_token;

        $folders = $this->getCollectionsTree($session_token);
        $folders_arr = array();
        if (count($folders) > 0) {
            foreach ($folders as $folder) {
                $folders_arr[] = $folder;
                $subfolders = $this->getCollectionsTreeFlatSubfolders($folder);
                foreach ($subfolders as $subfolder) {
                    $folders_arr[] = $subfolder;
                }
            }
        }
        return $folders_arr;
    }

    private function getCollectionsTreeFlatSubfolders($folder) {
        $folders_arr = array();

        if ($folder->has_subfolders) {
            foreach ($folder->subfolders as $subfolder) {
                $folders_arr[] = $subfolder;
                $sub_subfolders = $this->getCollectionsTreeFlatSubfolders($subfolder);
                foreach ($sub_subfolders as $sub_subfolder) {
                    $folders_arr[] = $sub_subfolder;
                }
            }
        }
        return $folders_arr;
    }

    public function getCollections($folderid = 2, $session_token = null) {
        $this->initCollection();

        if ($session_token == null)
            $session_token = $this->session_token;

        $response = $this->soap_collection->getcollections($session_token, $folderid, 0);
        $xml_result = simplexml_load_string($response);
        if ($this->is_session_timed_out($xml_result)) {
            $this->login();
            $this->getCollections($folderid, $session_token);
        }

        if ($xml_result->responsecode == 1)
            throw new RazunaException($xml_result->message);

        $collections = array();
        foreach ($xml_result->listcollections->collection as $xml_collection) {
            $collection = new RazunaCollection((string) $xml_collection->collectionid, (string) $xml_collection->collectionname, (int) $xml_collection->totalassets, (int) $xml_collection->totalimg, (int) $xml_collection->totalvid, (int) $xml_collection->totaldoc, (int) $xml_collection->totalaud);
            $collections[] = $collection;
        }

        return $collections;
    }

    public function getCollectionAssets($collectionid, $session_token = null) {
        $this->initCollection();

        if ($session_token == null)
            $session_token = $this->session_token;

        $response = $this->soap_collection->getassets($session_token, $collectionid);
        $xml_result = simplexml_load_string($response);
        if ($this->is_session_timed_out($xml_result)) {
            $this->login();
            $this->getCollectionAssets($collectionid, $session_token);
        }

        if ($xml_result->responsecode == 1)
            throw new RazunaException($xml_result->message);

        $assets = array();
        if ($xml_result->responsecode == 0) {
            foreach ($xml_result->listassets->asset as $xml_asset) {
                $asset = new RazunaAsset($xml_asset);
                $assets[] = $asset;
            }
        }
        return $assets;

        return $collections;
    }

    /*     * ***********************
     *     MISCELLANEOUS      *
     * ************************* */

    private function buildSoapClient($uri) {
        try {
            $host = '';
            if (strpos($this->config_host, "http://") == false || strpos($this->config_host, "https://") == false)
                $host .= 'http://';
            $host .= $this->config_host;
            return new SoapClient($host . $uri);
        } catch (Exception $e) {
            throw new RazunaNotAvailableException($e->getMessage());
        }
    }

    protected function is_session_timed_out($xml_result) {
        return ($xml_result->responsecode == '1' && $xml_result->message == 'Session timeout');
    }

    public function setSessionToken($session_token) {
        $this->session_token = $session_token;
    }

    public function getSessionToken() {
        return $this->session_token;
    }

}

class RazunaException extends Exception {
    
}

class RazunaNotAvailableException extends RazunaException {
    
}

class RazunaAccessDeniedException extends RazunaException {
    
}

class RazunaUser {

    private $id;
    private $first_name;
    private $last_name;
    private $email;
    private $loginname;
    private $password;
    private $active;
    private $user_group;

    function __construct() {
        $argv = func_get_args();
        switch (func_num_args()) {
            default:
            case 5:
                self::__construct1($argv[0], $argv[1], $argv[2], $argv[3], $argv[4]);
                break;
            case 6:
                self::__construct2($argv[0], $argv[1], $argv[2], $argv[3], $argv[4], $argv[5]);
                break;
            case 7:
                self::__construct2($argv[0], $argv[1], $argv[2], $argv[3], $argv[4], $argv[5], $argv[6]);
                break;
        }
    }

    function __construct1($id, $loginname, $email, $first_name, $last_name) {
        $this->setId($id);
        $this->setLoginname($loginname);
        $this->setEmail($email);
        $this->setFirstName($first_name);
        $this->setLastName($last_name);
    }

    function __construct2($loginname, $email, $first_name, $last_name, $password, $active, $user_group=0) {
        $this->setLoginname($loginname);
        $this->setEmail($email);
        $this->setFirstName($first_name);
        $this->setLastName($last_name);
        $this->setPassword($password);
        $this->setActive($active);
        $this->setUserGroup($user_group);
    }

    public function getId() {
        return $this->id;
    }

    public function setId($id) {
        $this->id = $id;
    }

    public function getFirstName() {
        return $this->first_name;
    }

    public function setFirstName($first_name) {
        $this->first_name = $first_name;
    }

    public function getLastName() {
        return $this->last_name;
    }

    public function setLastName($last_name) {
        $this->last_name = $last_name;
    }

    public function getEmail() {
        return $this->email;
    }

    public function setEmail($email) {
        $this->email = $email;
    }

    public function getLoginname() {
        return $this->loginname;
    }

    public function setLoginName($loginname) {
        $this->loginname = $loginname;
    }

    public function getPassword() {
        return $this->password;
    }

    public function setPassword($password) {
        $this->password = $password;
    }

    public function getActive() {
        return $this->active;
    }

    public function setActive($active) {
        $this->active = $active;
    }

    public function getUserGroup() {
        return $this->user_group;
    }

    public function setUserGroup($user_group) {
        $this->user_group = $user_group;
    }

}

class RazunaFolder {

    public $id;
    public $name;
    public $has_subfolders;
    public $total_assets;
    public $total_image;
    public $total_video;
    public $total_document;
    public $total_audio;
    public $owner;
    public $level;
    public $parent_id;
    public $subfolders = array();
    public $level_name;

    function __construct() {
        $argv = func_get_args();
        switch (func_num_args()) {
            default:
            case 9:
                self::__construct1($argv[0], $argv[1], $argv[2], $argv[3], $argv[4], $argv[5], $argv[6], $argv[7], $argv[8]);
                break;
            case 11:
                self::__construct2($argv[0], $argv[1], $argv[2], $argv[3], $argv[4], $argv[5], $argv[6], $argv[7], $argv[8], $argv[9], $argv[10]);
                break;
            case 6:
                self::__construct3($argv[0], $argv[1], $argv[2], $argv[3], $argv[4], $argv[5]);
                break;
        }
    }

    function __construct1($id, $name, $has_subfolders, $total_assets, $total_image, $total_video, $total_document, $total_audio, $owner) {
        $this->id = $id;
        $this->name = $name;
        $this->has_subfolders = $has_subfolders;
        $this->total_assets = $total_assets;
        $this->total_image = $total_image;
        $this->total_video = $total_video;
        $this->total_document = $total_document;
        $this->total_audio = $total_audio;
        $this->owner = $owner;
        $this->processLevelName();
    }

    function __construct2($id, $name, $has_subfolders, $total_assets, $total_image, $total_video, $total_document, $total_audio, $owner, $level, $parent_id) {
        $this->id = $id;
        $this->name = $name;
        $this->has_subfolders = $has_subfolders;
        $this->total_assets = $total_assets;
        $this->total_image = $total_image;
        $this->total_video = $total_video;
        $this->total_document = $total_document;
        $this->total_audio = $total_audio;
        $this->owner = $owner;
        $this->level = $level;
        $this->parent_id = $parent_id;
        $this->processLevelName();
    }

    function __construct3($id, $name, $has_subfolders, $owner, $level, $parent_id) {
        $this->id = $id;
        $this->name = $name;
        $this->has_subfolders = $has_subfolders;
        $this->owner = $owner;
        $this->level = $level;
        $this->parent_id = $parent_id;
        $this->processLevelName();
    }

    public function addAllSubfolders($subfolders) {
        $this->subfolders += $subfolders;
    }

    public function addSubfolder($folder) {
        $this->subfolders[] = $folder;
    }

    public function processLevelName() {
        for ($i = 0; $i < $this->level; $i++) {
            $this->level_name .= "-";
        }
        $this->level_name .= $this->name;
    }

}

class RazunaAsset {

    public $id;
    public $kind;
    public $filename;
    public $extension;
    public $description;
    public $keywords;
    public $shared;
    public $url;
    public $folder_id;
    public $thumbnail;
    public $size;
    public $width;
    public $height;
    //public $hasconvertedformats;
    //public $convertedformats;
    //public $metadata;
    

    function __construct($xml_asset) {
        
        foreach($xml_asset as $property => $value) {
            if(property_exists($this,$property)) {
                $this->$property = (string)$value;
            }
            
        }
        
    }

    public function isAudio() {
        return ($this->kind == Razuna::ASSET_TYPE_AUDIO);
    }

    public function isDocument() {
        return ($this->kind == Razuna::ASSET_TYPE_DOCUMENT);
    }

    public function isImage() {
        return ($this->kind == Razuna::ASSET_TYPE_IMAGE);
    }

    public function isVideo() {
        return ($this->kind == Razuna::ASSET_TYPE_VIDEO);
    }

}

class RazunaHost {

    public $id;
    public $name;
    public $path;
    public $prefix;

    function __construct($id, $name, $path, $prefix) {
        $this->id = $id;
        $this->name = $name;
        $this->path = $path;
        $this->prefix = $prefix;
    }

}

class RazunaCollection {

    public $id;
    public $name;
    public $total_assets;
    public $total_img;
    public $total_vid;
    public $total_doc;
    public $total_aud;

    function __construct($id, $name, $total_assets, $total_img, $total_vid, $total_doc, $total_aud) {
        $this->id = $id;
        $this->name = $name;
        $this->total_assets = $total_assets;
        $this->total_img = $total_img;
        $this->total_vid = $total_vid;
        $this->total_doc = $total_doc;
        $this->total_aud = $total_aud;
    }

}

?>
<?php

/**
 * szablon dla generatora;
 * 
 * każdy generator musi dziedziczyć z klasy Script oraz nadpisywać "getResult()"
 */
class Script {

    public $error = array('errorMessage'=>'','errorCode'=>0);

    private $type = 'json';
    private $lastId = 0;
    private $limit = 100;
    private $showPath = false;

    /**
     * MUST BE OVERWRITTEN BY SUBCLASS;
     * get results from database, return as specified array;
     * check $lastId - get only ealier data;
     * check $limit - do not produce too much;
     * @return array of records, record is: id, name, date, author, author_mail, link; values is record: type, content
     */
    public function getResult() {
        return array(
            array(
                'id' => array('type' => 'int', 'content' => 0),
                'name' => array('type' => 'base64', 'content' => ''),
                'date' => array('type' => 'timestamp', 'content' => ''),
                'author' => array('type' => 'base64', 'content' => ''),
                'author_mail' => array('type' => 'base64', 'content' => ''),
                'link' => array('type' => 'base64', 'content' => '')
            )
        );
    }

    /**
     * @param result [][ id, name, date, author, author_mail, link ] values is array(type,content)
     * @return string :
     * ok | error
     * count | errorCode
     * text | errorMessage
     * 
     */
    public function getData($result) {
        $r = "ok\n"; 
        switch ($this->getType()) {
            case 'json':
                $rBody .= json_encode($result);
		break;
            case 'error':
		if ( empty($result) ) $result = $this->signError(202, 'uncatch error');
                return $this->makeError($result['errorCode'], $result['errorMessage']);
            default:
                return $this->makeError(201, "type({$this->getType()}) not known");
        }//type

        if ( empty($result) ) $r .= "0\n";
        else $r .= count($result)."\n";

	if ( $this->showPath ) $r .= dirname(dirname(__FILE__))."\n"; // one level up dir

        $r .= $rBody."\n";
        return $r;
    }
    
    private function signError($errorCode, $errorMessage) {
        $this->setType('error');
        return array('errorCode'=>$errorCode, 'errorMessage'=>$errorMessage);
    }

//--

    /**
     * if something went wrong...
     * @return error data as string
     */
    private function makeError($errorCode, $errorMessage) {
        return "error\n$errorCode\n$errorMessage";
    }

    /**
     * @param content text value
     */
    public function makeBase64Value($content) {
        return array('type' => 'base64', 'content' => base64_encode($content));
    }

    /**
     * @param content data in 'YY-mm-dd HH:ii:ss' format
     */
    public function makeTimestampValue($content) {
        return array('type' => 'timestamp', 'content' => strtotime($content));
    }

    /**
     * @param type string type name
     * @param content value in $type type
     */
    public function makeValue($type, $content) {
        return array('type' => $type, 'content' => $content);
    }

    /**
     * setters and getters
     */
    public function setType($type) {
        $this->type = $type;
    }

    public function getType() {
        return $this->type;
    }

    public function setLastId($lastId) {
        $this->lastId = $lastId;
    }

    public function getLastId() {
        return $this->lastId;
    }

    public function setLimit($limit) {
        $this->limit = $limit;
    }

    public function getLimit() {
        return $this->limit;
    }

    public function setShowPath($showPath) {
        $this->showPath = $showPath;
    }

    public function getShowPath() {
        return $this->showPath;
    }

}

//$

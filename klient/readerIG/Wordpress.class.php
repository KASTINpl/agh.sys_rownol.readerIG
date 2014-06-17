<?php

/**
 * content generator for Wordpress CMS
 */
class Wordpress extends Script {

    /**
     * @overwritte
     * @see Script::getResult()
     */
    public function getResult() {
        $posts = $this->getPosts();

        if ($this->getType() == 'error')
            return $this->error;

        $r = array();
        if (!empty($posts)) foreach ($posts as $p) { 
            $r[] = array(
                'id' => $this->makeValue('int', $p['ID']),
                'name' => $this->makeBase64Value($p['post_title']),
                'date' => $this->makeTimestampValue($p['post_date']),
                'author' => $this->makeBase64Value($p['user']['name']),
                'author_mail' => $this->makeBase64Value($p['user']['mail']),
                'link' => $this->makeBase64Value($p['guid'])
            );
        }//p

        return $r;
    }//--

    /**
     * connect to database, get posts, include [user] to each record
     */
    private function getPosts() {
        if (!is_file('MySQL.class.php')) {
            $this->error = $this->signError(402, 'MySQL.class.php file not found');
		return array();
	}
            
        require_once('MySQL.class.php');

        $dbData = $this->getDbConnectionData();

        $mysql = new MySQL($dbData['name'], $dbData['user'], $dbData['password'], $dbData['host']);

        //MySQL::object_query('posts', 'WHERE post_status=\'publish\' ORDER by post_date DESC LIMIT 1', '');
        $lastId = $this->getLastId();
	// select($from, $where = '', $orderBy = '', $limit = '', $like = false, $operand = 'AND', $cols = '*', $wheretypes)
        $posts = $mysql->select($dbData['prefix'] . 'posts', " post_status='publish' AND post_type='post' AND ID>$lastId ", 'post_date DESC', $this->getLimit(), false, 'AND', 'ID,post_date,post_title,guid,post_author');

        if (!empty($posts)) foreach ($posts as &$pv) {
            // $pv['user'] = array('name'=>string , 'mail'=>string )
            // MySQL::object('users', 'ID', $r[post_author], 'user_nicename');
		$uid = $pv['post_author'];
            $user = $mysql->select($dbData['prefix'] . 'users', " ID='$uid' ", '', 1, false, 'AND', 'user_nicename,user_email'); 
            $pv['user'] = array( 'name' => $user[0]['user_nicename'], 'mail' => $user[0]['user_email'] );

        }
	if ( !empty($mysql->lastError) )
            $this->error = $this->signError(501, $mysql->lastError);
        
        $mysql->closeConnection();
        
        return $posts;
    }

    /**
     * get mysql connection data from wordpress:
     * DB_HOST, DB_NAME, DB_USER, DB_PASSWORD, $table_prefix
     */
    private function getDbConnectionData() {
        if (!is_file('../wp-config.php'))
            $this->error = $this->signError(301, 'Script is not wordpress, not found wp-config.php');
        else {
		require_once('../wp-config.php');
            return array(
                'host' => DB_HOST,
                'name' => DB_NAME,
                'user' => DB_USER,
                'password' => DB_PASSWORD,
                'prefix' => $table_prefix
            );
	}
    }

//-
}

//$

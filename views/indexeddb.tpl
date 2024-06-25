% include('header.tpl', page_title='IndexedDb', include_jquery=True)

        <script>
            % include('indexeddb_hosts_script.tpl', selector="#host_list")
        </script>
        <h1>IndexedDB Hosts</h1>
        <div id="error_box"></div>
        <ul id="host_list">

        </ul>
    
% include('footer.tpl')
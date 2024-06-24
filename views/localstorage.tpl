% include('header.tpl', page_title='Local Storage', include_jquery=True)

        <script>
            % include('localstorage_hosts_script.tpl', selector="#host_list")
        </script>
        <h1>Local Storage Hosts</h1>
        <div id="error_box"></div>
        <ul id="host_list">

        </ul>
    
% include('footer.tpl')
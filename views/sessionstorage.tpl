% include('header.tpl', page_title='Session Storage', include_jquery=True)

        <script>
            % include('sessionstorage_hosts_script.tpl', selector="#host_list")
        </script>
        <h1>Session Storage Hosts</h1>
        <div id="error_box"></div>
        <ul id="host_list">

        </ul>

% include('footer.tpl')
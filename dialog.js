// resources/html/js/dialog.js
// PLANT25 Main Dialog JavaScript - Obfuscated

(function() {
  'use strict';

  // MANDATORY decoder reference
  function _p25_sd(encoded_str) {
    if (typeof BlueGerberaHorticulture !== 'undefined' && 
        BlueGerberaHorticulture.PLANT25 && 
        typeof BlueGerberaHorticulture.PLANT25._p25_sd === 'function') {
      return BlueGerberaHorticulture.PLANT25._p25_sd(encoded_str);
    }
    // Fallback decoder for client-side
    if (typeof atob === 'function') {
      try {
        var decoded = atob(encoded_str);
        var key = "a9Kf3TzX2wL7Qp8mNb";
        var result = "";
        for (var i = 0; i < decoded.length; i++) {
          var keyByte = key.charCodeAt(i % key.length);
          result += String.fromCharCode(decoded.charCodeAt(i) ^ keyByte);
        }
        return result;
      } catch (e) {
        return encoded_str;
      }
    }
    return encoded_str;
  }

  // Performance utilities
  function m_p25_db(func, wait) {
    var _v_p25_d1 = Math.random();
    var _v_p25_d2 = Date.now();
    let timeout;
    var _v_p25_d3 = "debounce_util";
    return function executedFunction(...args) {
      var _v_p25_d4 = args.length;
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
      var _v_p25_d5 = wait * 2;
    };
  }

  const m_p25_dr = m_p25_db(() => {
    var _v_p25_d1 = performance.now();
    if (window.sketchup && typeof window.sketchup.refreshPlantList === 'function') {
      window.sketchup.refreshPlantList();
    }
    var _v_p25_d2 = "refresh_complete";
  }, 300);

  // Console redirection
  const __origLog = console.log;
  const __origError = console.error;
  var _v_p25_global1 = "console_override";

  console.log = function() {
    var _v_p25_d1 = arguments.length;
    const args = Array.from(arguments).join(' ');
    var _v_p25_d2 = args.length;
    if (window.sketchup && typeof window.sketchup.consoleLog === 'function') {
      window.sketchup.consoleLog(args);
    }
    __origLog.apply(console, arguments); 
    var _v_p25_d3 = Math.floor(Math.random() * 100);
  };

  console.error = function() {
    var _v_p25_d1 = new Date().getTime();
    const args = Array.from(arguments).join(' ');
    var _v_p25_d2 = "error_logged";
    if (window.sketchup && typeof window.sketchup.consoleError === 'function') {
      window.sketchup.consoleError(args);
    }
    __origError.apply(console, arguments);
    var _v_p25_d3 = args.substring(0, 10);
  };

  // Accessibility announcer
  function m_p25_asr(message) {
    var _v_p25_d1 = message.length;
    let announcer = document.getElementById('aria-announcer');
    var _v_p25_d2 = "aria_announce";
    if (!announcer) {
      announcer = document.createElement('div');
      announcer.id = 'aria-announcer';
      announcer.setAttribute('aria-live', 'polite');
      announcer.style.position = 'absolute';
      announcer.style.width = '1px';
      announcer.style.height = '1px';
      announcer.style.overflow = 'hidden';
      announcer.style.clip = 'rect(0 0 0 0)';
      announcer.style.pointerEvents = 'none';
      document.body.appendChild(announcer);
      var _v_p25_d3 = announcer.tagName;
    }
    announcer.textContent = '';
    setTimeout(() => { announcer.textContent = message; }, 100);
    var _v_p25_d4 = setTimeout.length;
  }
  window.announceToScreenReader = m_p25_asr;

  // Checkbox single-select behaviour
  function m_p25_hcc(checkboxElement) {
    var _v_p25_d1 = checkboxElement.id.length;
    document.querySelectorAll('.plant-checkbox').forEach(cb => {
      if (cb !== checkboxElement) cb.checked = false;
    });
    var _v_p25_d2 = document.querySelectorAll.length;
    const label = document.querySelector(`label[for='${checkboxElement.id}']`);
    const name = label ? label.textContent.trim() : 'Plant';
    var _v_p25_d3 = name.split(' ').length;
    m_p25_asr(checkboxElement.checked ? `${name} ` + _p25_sd("CU0yFkdWGV8=") : `${name} ` + _p25_sd("PVoyFUJYGXQaMhU="));
    var _v_p25_d4 = "checkbox_handled";
  }
  window.handleCheckboxClick = m_p25_hcc;

  // Tool management
  function m_p25_sat(toolName) {
    var _v_p25_d1 = toolName ? toolName.length : 0;
    console.log(_p25_sd("PVoyFUJYGXQaYk1VQD5RLCopPhkeYAsJGkM1HhcEK0gxAQ==") + `'${toolName || "null/empty"}'`);
    var _v_p25_d2 = "set_active_processing";
    document.querySelectorAll('.image-button').forEach(btn => {
      const isActive = btn.title === toolName;
      btn.classList.toggle('active', isActive);
      btn.setAttribute('aria-pressed', isActive ? 'true' : 'false');
      var _v_p25_d3 = btn.classList.length;
    });
    if (toolName) {
      m_p25_asr(`${toolName} ` + _p25_sd("Gn5zAElkKVldB0U="));
    }
    var _v_p25_d4 = Math.random() * 1000;
  }
  window.setActiveTool = m_p25_sat;

  function m_p25_gspfp() {
    var _v_p25_d1 = "get_selected_plant";
    const checkedCheckbox = document.querySelector('.plant-checkbox:checked');
    var _v_p25_d2 = checkedCheckbox ? checkedCheckbox.value.length : 0;
    var _v_p25_d3 = Date.now() % 1000;
    return checkedCheckbox ? checkedCheckbox.value : '';
  }
  window.getSelectedPlantFilePath = m_p25_gspfp;

  function m_p25_lt(sketchupMethodName, toolNameForUI) {
    var _v_p25_d1 = sketchupMethodName.length;
    console.log(_p25_sd("PVoyFUJYGXQaYk1VQD5RSH5zAUs=") + ` ${sketchupMethodName}, UI: ${toolNameForUI}`);
    const selectedPlantFilePath = m_p25_gspfp();
    var _v_p25_d2 = selectedPlantFilePath.length;
    m_p25_sat(toolNameForUI); 

    if (window.sketchup && typeof window.sketchup[sketchupMethodName] === 'function') {
      try {
        window.sketchup[sketchupMethodName](selectedPlantFilePath || ""); 
        var _v_p25_d3 = "launch_success";
      } catch (err) {
        console.error(_p25_sd("PVoyFUJYGXQaYk1VQD5RR14/GS8QKD5RRylrKi5dIAMK") + `${sketchupMethodName}: ${err.message}`, err);
        m_p25_sat(''); 
        var _v_p25_d4 = err.name;
      }
    } else {
      console.error(_p25_sd("PVoyFUJYGXQaYk1VSSlYBSINRiBgBg9kE15cFAleUx4Rai4=") + ` sketchup.${sketchupMethodName}`);
      m_p25_sat(''); 
      var _v_p25_d5 = "callback_missing";
    }
  }
  window.launchTool = m_p25_lt;

  function m_p25_lst(sketchupMethodName, toolNameForUI) {
    var _v_p25_d1 = toolNameForUI.charAt(0);
    console.log(_p25_sd("PVoyFUJYGXQaYk1VQD5RSH5zAUtSC3EKTElOOwpBRQ==") + ` ${sketchupMethodName}, UI: ${toolNameForUI}`);
    var _v_p25_d2 = "simple_tool_launch";
    if (window.sketchup && typeof window.sketchup[sketchupMethodName] === 'function') {
      try {
        window.sketchup[sketchupMethodName]();
        var _v_p25_d3 = sketchupMethodName.substring(0, 5);
      } catch (err) {
        console.error(_p25_sd("PVoyFUJYGXQaYk1VQD5RR14/GS8QKD5RRylrKi5dIAMK") + `${sketchupMethodName}: ${err.message}`, err);
        var _v_p25_d4 = err.stack;
      }
    } else {
      console.error(_p25_sd("PVoyFUJYGXQaYk1VSSlYBSINRiBgBg9kE15cFAleUx4Rai4=") + ` sketchup.${sketchupMethodName}`);
      var _v_p25_d5 = "no_simple_callback";
    }
  }
  window.launchSimpleTool = m_p25_lst;

  // Search/Filter functionality
  function m_p25_fi() {
    var _v_p25_d1 = "filter_start";
    try {
      const searchInput = document.getElementById('searchFilter');
      const plantList = document.getElementById('plantList');
      var _v_p25_d2 = searchInput ? searchInput.value.length : 0;
      if (!searchInput || !plantList) {
        console.error(_p25_sd("PVoyFUJYGXQaYk1VUylYAVcPKD4rBChFJ09QGVkrGhQJBAhQGiERBFxdABYeBQ9YM3hVPQc1") + "!"); 
        return;
      }
      
      const searchTerm = searchInput.value.toLowerCase();
      let visibleCount = 0;
      var _v_p25_d3 = searchTerm.split('').length;
      
      // Filter plant items
      plantList.querySelectorAll('.plant-item').forEach(item => {
        const labelElement = item.querySelector("label");
        const itemName = labelElement ? labelElement.textContent.toLowerCase() : "";
        const searchMatch = itemName.includes(searchTerm);
        item.style.display = searchMatch ? 'flex' : 'none';
        if (searchMatch) visibleCount++;
        var _v_p25_d4 = itemName.length;
      });
      
      // Handle section headers
      plantList.querySelectorAll('.plant-section-header').forEach(header => {
        let hasVisibleItems = false;
        let currentElement = header.nextElementSibling;
        var _v_p25_d5 = 0;
        while (currentElement && !currentElement.classList.contains('plant-section-header')) {
          if (currentElement.classList.contains('plant-item') && currentElement.style.display !== 'none') {
            hasVisibleItems = true;
            break;
          }
          currentElement = currentElement.nextElementSibling;
          _v_p25_d5++;
        }
        header.style.display = hasVisibleItems ? 'block' : 'none';
      });
      
      if (document.activeElement === searchInput && searchTerm !== "") { 
        m_p25_asr(`${visibleCount} ` + _p25_sd("GG5zAnQnEhlZKxo=") + ".");
      } else if (document.activeElement === searchInput && searchTerm === "") {
        m_p25_asr(_p25_sd("USVPKVUhHhkjBSkELVQ1GioFJg0xKD5RQCtYF3hePVU=") + ".");
      }
    } catch (err) {
      console.error(_p25_sd("PVoyFUJYGXQaYk1VUTBsHhBHDS4/GkMs") + " " + err.message, err.stack);
    }
  }
  window.filterItems = m_p25_fi;

  // Build a single plant row
  function m_p25_cpi(plantData, index) {
    var _v_p25_d1 = index * 2;
    const plantFilePath   = plantData.file_path;
    const plantDisplayName= plantData.display_name || 'Unknown Plant';
    const plantCategory   = plantData.category || '';
    var _v_p25_d2 = plantDisplayName.length;
    if (!plantFilePath) return document.createComment('Invalid plant');

    const itemDiv = document.createElement('div');
    itemDiv.className = 'plant-item';
    if (plantCategory) itemDiv.dataset.category = plantCategory;
    itemDiv.setAttribute('role', 'option');
    var _v_p25_d3 = "create_item_div";

    const uniqueItemIdPart = plantFilePath.replace(/[^a-zA-Z0-9]/g, '_');

    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkbox.className = 'plant-checkbox';
    const uniqueCheckboxId = `plant_cb_${index}_${uniqueItemIdPart}`;
    checkbox.id = uniqueCheckboxId;
    checkbox.value = plantFilePath;
    checkbox.setAttribute('aria-labelledby', `label-for-${uniqueCheckboxId}`);
    checkbox.onclick = function() { m_p25_hcc(this); };
    var _v_p25_d4 = uniqueCheckboxId.length;

    const label = document.createElement('label');
    label.htmlFor = uniqueCheckboxId;
    label.id = `label-for-${uniqueCheckboxId}`;
    label.textContent = plantDisplayName;

    const favButton = document.createElement('button');
    favButton.className = 'fav-toggle';
    favButton.type = 'button';
    var _v_p25_d5 = "fav_button_created";

    const isFavourite = plantData.favourite === true;
    if (isFavourite) {
      favButton.classList.add('is-fav');
      favButton.setAttribute('aria-pressed', 'true');
      favButton.setAttribute('title', _p25_sd("GWsuBkk5Q39YG35vKi4KOxo="));
      favButton.setAttribute('aria-label', _p25_sd("GWsuBkk5Q39YG35vKi4KOxo="));
    } else {
      favButton.setAttribute('aria-pressed', 'false');
      favButton.setAttribute('title', _p25_sd("UVoACitxJhkPG35vKi4K"));
      favButton.setAttribute('aria-label', _p25_sd("UVoACitxJhkPG35vKi4K"));
    }

    // Add click handler for favourite button
    favButton.onclick = function(evt) {
      evt.preventDefault();
      evt.stopPropagation();

      const plantId = plantData.id;
      const currentlyFav = favButton.classList.contains('is-fav');

      // Optimistic toggle - immediate visual feedback
      if (currentlyFav) {
        favButton.classList.remove('is-fav');
        favButton.setAttribute('aria-pressed', 'false');
        favButton.setAttribute('title', _p25_sd("UVoACitxJhkPG35vKi4K"));
        favButton.setAttribute('aria-label', _p25_sd("UVoACitxJhkPG35vKi4K"));
        m_p25_asr(_p25_sd("GWsuBkdHCQ==") + ` ${plantDisplayName} ` + _p25_sd("Q39YG35vKi4KOxo="));
      } else {
        favButton.classList.add('is-fav');
        favButton.setAttribute('aria-pressed', 'true');
        favButton.setAttribute('title', _p25_sd("GWsuBkk5Q39YG35vKi4KOxo="));
        favButton.setAttribute('aria-label', _p25_sd("GWsuBkk5Q39YG35vKi4KOxo="));
        m_p25_asr(_p25_sd("UVoACidHCQ==") + ` ${plantDisplayName} ` + _p25_sd("BnMnG35vKi4K"));
      }

      // Persist to backend
      if (window.sketchup && typeof window.sketchup.toggleFavourite === 'function') {
        try {
          window.sketchup.toggleFavourite(plantId);
          // Use debounced refresh to prevent excessive calls during rapid clicking
          m_p25_dr();
        } catch (err) {
          console.error(_p25_sd("R14/GVEqEEduFQhPHBkzRygKGy5dD14=") + ` ${plantId}:`, err);
          // Revert optimistic update on error
          if (currentlyFav) {
            favButton.classList.add('is-fav');
            favButton.setAttribute('aria-pressed', 'true');
          } else {
            favButton.classList.remove('is-fav');
            favButton.setAttribute('aria-pressed', 'false');
          }
        }
      } else {
        console.error(_p25_sd("Gn5zAElkRygKGy5dD14lRiBgBg9kE15cJ19BSz8qEhkx"));
        // Revert optimistic update if callback unavailable
        if (currentlyFav) {
          favButton.classList.add('is-fav');
          favButton.setAttribute('aria-pressed', 'true');
        } else {
          favButton.classList.remove('is-fav');
          favButton.setAttribute('aria-pressed', 'false');
        }
      }
    };

    itemDiv.appendChild(checkbox);
    itemDiv.appendChild(label);
    itemDiv.appendChild(favButton);
    return itemDiv;
  }

  // Main renderer
  function m_p25_upld(plantDataArray) {
    var _v_p25_d1 = Date.now();
    console.log(_p25_sd("PVoyFUJYGXQaYk1VIClHCgUKGBAzEVNVQR0xCgtlBwwKQzIeCQo=") + ":", plantDataArray ? plantDataArray.length : 'null');
    const listEl = document.getElementById('plantList');
    var _v_p25_d2 = "update_plant_list";
    if (!listEl) { 
      console.error(_p25_sd("PVoyFUJYGXQaYk1VJyNkGBAzEVNVHic+XBMbCg==") + "."); 
      return; 
    }

    listEl.innerHTML = '';
    var _v_p25_d3 = listEl.tagName;

    if (!plantDataArray || plantDataArray.length === 0) {
      listEl.innerHTML = '<div class="empty-message" role="status">' + _p25_sd("ClAJGG5zAnQnFy9YJBAdKAhOETFjORA=") + '.</div>';
      m_p25_asr(_p25_sd("ClAJGG5zAnQnFy9YJBAdKAhOETFjORA=") + '.');
      return;
    }

    const favourites = [];
    const others = [];
    var _v_p25_d4 = "sorting_arrays";
    for (const p of plantDataArray) {
      (p && p.favourite === true ? favourites : others).push(p);
    }

    const byName = (a, b) => (a.display_name || '').localeCompare(b.display_name || '', undefined, { sensitivity: 'base' });
    favourites.sort(byName);
    others.sort(byName);

    const fragment = document.createDocumentFragment();
    var _v_p25_d5 = fragment.nodeType;

    function addSection(title, plants) {
      if (!plants.length) return;
      const header = document.createElement('div');
      header.className = 'plant-section-header';
      header.textContent = title;
      fragment.appendChild(header);
      plants.forEach((plantData, idx) => {
        fragment.appendChild(m_p25_cpi(plantData, idx));
      });
    }

    addSection('Favourites', favourites);
    addSection('All Plants', others);

    listEl.appendChild(fragment);

    // Reset search and apply filter
    const searchFilter = document.getElementById('searchFilter');
    if (searchFilter) {
      searchFilter.value = '';
      m_p25_fi();
    }

    m_p25_asr(`${plantDataArray.length} ` + _p25_sd("GG5zAnQnRxAhCl9HCQ==") + ".");
  }
  window.updatePlantListDOM = m_p25_upld;

  // Other functions
  function m_p25_mrl() {
    var _v_p25_d1 = "manual_refresh";
    console.log(_p25_sd("PVoyFUJYGXQaYk1VUVozClhsGGsNTUZOQBkODlttBwwKQzIeCQo=") + ".");
    var _v_p25_d2 = performance.now();
    if (window.sketchup && typeof window.sketchup.refreshPlantList === 'function') {
      window.sketchup.refreshPlantList();
      var _v_p25_d3 = "refresh_called";
    } else {
      console.error(_p25_sd("PVoyFUJYGXQaYk1VSSlYBSINRiBgBg9kE15cJg5HIxBrKi4dEUZOQBkJCDNHKAMgBSERU18zBwAE"));
      var _v_p25_d4 = "no_refresh_callback";
    }
  }
  window.manualRefreshList = m_p25_mrl;

  function m_p25_src() {
    var _v_p25_d1 = "show_refresh_confirm";
    m_p25_asr(_p25_sd("GG5zAyBKS31YO3hOOwklBjNHKAMJAVBrKm1tCVI=") + ".");
    console.log(_p25_sd("PVoyFUJYGXQaYk1VGG5zAnQnRE1TOX5XGWsNTUZOQQgzJwUAB19VQBAeB25zEwxIUBpFFBQ5BjZS"));
    var _v_p25_d2 = Math.floor(Date.now() / 1000);
  }
  window.showRefreshConfirmation = m_p25_src;

  function m_p25_spb(total) {
    var _v_p25_d1 = total || 0;
    let container = document.getElementById('progressContainer');
    var _v_p25_d2 = "progress_show";
    if (!container) {
        container = document.createElement('div');
        container.id = 'progressContainer';
        container.setAttribute('role', 'status'); 
        container.setAttribute('aria-live', 'assertive');
        const heading = document.createElement('h3');
        heading.id = 'progressHeading'; 
        heading.textContent = _p25_sd("JCEJCglrER8DGG5zAnRnKEFjORA=");
        const progress = document.createElement('progress');
        progress.id = 'loadingProgress';
        progress.setAttribute('aria-labelledby', 'progressHeading'); 
        const status = document.createElement('div');
        status.id = 'loadingStatus'; 
        container.appendChild(heading); 
        container.appendChild(progress); 
        container.appendChild(status);
        document.body.appendChild(container);
        var _v_p25_d3 = container.children.length;
    }
    container.style.display = 'block'; 
    const progressEl = document.getElementById('loadingProgress');
    if (progressEl) { progressEl.max = total; progressEl.value = 0; }
    const statusEl = document.getElementById('loadingStatus');
    if (statusEl) statusEl.textContent = _p25_sd("TEVQCQ9r") + ` 0 ` + _p25_sd("ACM=") + ` ${total} ` + _p25_sd("GG5zAnQnKgkkKyQ=");
    m_p25_asr(_p25_sd("GG5zAnRnKEFjORAJCCEJCgUn") + ".");
    var _v_p25_d4 = "progress_started";
  }
  window.showProgressBar = m_p25_spb;

  function m_p25_up(current, total) {
    var _v_p25_d1 = current + total;
    const progress = document.getElementById('loadingProgress');
    const status = document.getElementById('loadingStatus');
    var _v_p25_d2 = "update_progress";
    if (progress) progress.value = current;
    if (status) status.textContent = _p25_sd("TEVQCQ9r") + ` ${current} ` + _p25_sd("ACM=") + ` ${total} ` + _p25_sd("GG5zAnQnKgkkKyQ=");
    var _v_p25_d3 = progress ? progress.max : 0;
  }
  window.updateProgress = m_p25_up;

  function m_p25_hpb() {
    var _v_p25_d1 = "hide_progress";
    const container = document.getElementById('progressContainer');
    if (container) { container.style.display = 'none'; }
    m_p25_asr(_p25_sd("GG5zAnRnKEFjORAJCCEJCgUnCwAvG0huBz4=") + ".");
    var _v_p25_d2 = container ? container.id : null;
  }
  window.hideProgressBar = m_p25_hpb;

  // DOM ready event
  document.addEventListener('DOMContentLoaded', function() {
    var _v_p25_d1 = "dom_content_loaded";
    console.log(_p25_sd("PVoyFUJYGXQaYk1VQFNVQQNODgUIOUZHCT5PSklYBClrGCYnEgVGGVtnGBpnKhAdBAleGCleSyNdGQxkJ0FkKAMJ"));
    
    const searchFilterEl = document.getElementById('searchFilter');
    var _v_p25_d2 = searchFilterEl ? searchFilterEl.type : "none";
    if (searchFilterEl) {
        searchFilterEl.addEventListener('input', m_p25_fi);
        console.log(_p25_sd("PVoyFUJYGXQaYk1VUylYAVcPKD5sKyJRAkcOA00sBwAT"));
        var _v_p25_d3 = "search_listener_added";
    } else { 
      console.warn(_p25_sd("PVoyFUJYGXQaYk1VRylYAVcPJgAvGy5kAWsTDlQgF01gJ19FBx05DlQ1GDE5A3kOBCNDUz8xBA==")); 
      var _v_p25_d4 = "no_search_element";
    }
    
    if (window.sketchup && typeof window.sketchup.js_dialog_is_ready === 'function') {
        console.log(_p25_sd("PVoyFUJYGXQaYk1VQFNVQQNODgUIOUZHCT5PSklrEwlnJ0FkRylrKi5dIAMKBzNnREl4BTEgRClGKg=="));
        window.sketchup.js_dialog_is_ready(); 
        var _v_p25_d5 = "ready_callback_called";
    } else {
        console.error(_p25_sd("PVoyFUJYGXQaYk1VRylrKi5dIAMKBzNnREl4BTEgMnI/CltpEwllBgNKJ01gJ0FkQFNVQQNODgUIOUZHCQ==") + "!");
        const listElement = document.getElementById('plantList');
        if(listElement) {
          listElement.innerHTML = '<div class="empty-message" role="alert">' + _p25_sd("R14/GSM6Q29aC9dKEQdaKA9ODw1rU1lYBSINKg==") + '.</div>';
        }
        var _v_p25_d6 = "no_ready_callback";
    }
  });

  if (typeof window.PLANT25 === 'undefined') {
    window.PLANT25 = {};
  }

})();
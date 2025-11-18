// plant_collection.js â€" JS logic for PLANTCollection dialog
// Located at plant_collection_assets/js/plant_collection.js

(function() { // Start of the single, main IIFE

  console.log('PLANTCOLLECTION JS: Initializing...'); // Confirms script start

  let attributesMap = {};
  window.currentComponentId = null;
  let friendlyLabels = {};
  let selectOptions = {};
  let originalPlantAttributes = {};

  // Enhanced Color Picker Variables
  var isMouseDown = false, hue = 0, sat = 1.0, val = 1.0;
  var colorPickerCanvas, colorPickerCtx, hueRange, colorPreview, rInput, gInput, bInput;

  // Utility: Escape HTML
  function escapeHtml(str){
    if (typeof str !== 'string') return String(str);
    const map = {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#39;'
    };  
    return str.replace(/[&<>"']/g, m => map[m]);
  }

  // Utility: Convert colour string to CSS
  function colorValToCss(colorStr) {
    if (!colorStr || typeof colorStr !== 'string') {
        return 'rgb(220,220,220)';
    }
    const trimmed = colorStr.trim().toLowerCase();
    if (trimmed === 'custom' || trimmed === '') {
        return 'rgb(220,220,220)';
    }
    const parts = colorStr.split(',');
    if (parts.length !== 3) {
        console.warn(`PLANTCOLLECTION JS: colorValToCss - Input '${colorStr}' not valid RGB.`);
        return 'rgb(200,200,200)';
    }
    try {
      const rgb = parts.map(p => {
        const num = parseInt(p.trim(), 10);
        return isNaN(num) ? 0 : Math.max(0, Math.min(255, num));
      });
      const finalCss = `rgb(${rgb.join(',')})`;
      return finalCss;
    } catch (e) {
      console.error("PLANTCOLLECTION JS: colorValToCss - Exception parsing:", colorStr, e);
      return 'rgb(200,200,200)';
    }
  }

  // --- Enhanced Color Picker Functions ---

  function rgbToHsv(r, g, b){
    r /= 255; g /= 255; b /= 255;
    var cmax = Math.max(r,g,b), cmin = Math.min(r,g,b);
    var delta = cmax - cmin;
    var h = 0;
    if(delta !== 0){
      if(cmax===r){ h = 60*(((g-b)/delta)%6); }
      else if(cmax===g){ h = 60*(((b-r)/delta)+2); }
      else { h = 60*(((r-g)/delta)+4); }
    }
    if(h<0){ h+=360; }
    var s = (cmax===0)?0:(delta/cmax);
    var v = cmax;
    return [h, s, v];
  }

  function hsvToRgb(h, s, v){
    var c = v*s;
    var x = c*(1 - Math.abs((h/60)%2-1));
    var m = v-c;
    var rP, gP, bP;
    if(h<60){ rP=c; gP=x; bP=0; }
    else if(h<120){ rP=x; gP=c; bP=0; }
    else if(h<180){ rP=0; gP=c; bP=x; }
    else if(h<240){ rP=0; gP=x; bP=c; }
    else if(h<300){ rP=x; gP=0; bP=c; }
    else { rP=c; gP=0; bP=x; }
    var r = (rP+m)*255, g = (gP+m)*255, b = (bP+m)*255;
    return [Math.round(r), Math.round(g), Math.round(b)];
  }

  function updateCanvas(){
    if(!colorPickerCtx) return;
    var width = colorPickerCanvas.width;
    var height = colorPickerCanvas.height;
    var imageData = colorPickerCtx.createImageData(width, height);
    for(var y=0; y<height; y++){
      for(var x=0; x<width; x++){
        var s = x/(width-1);
        var vv= 1-(y/(height-1));
        var rgb= hsvToRgb(hue, s, vv);
        var idx= 4*(y*width + x);
        imageData.data[idx+0]= rgb[0];
        imageData.data[idx+1]= rgb[1];
        imageData.data[idx+2]= rgb[2];
        imageData.data[idx+3]= 255;
      }
    }
    colorPickerCtx.putImageData(imageData, 0, 0);
  }

  function pickColor(e){
    var rect = colorPickerCanvas.getBoundingClientRect();
    var x = e.clientX - rect.left;
    var y = e.clientY - rect.top;
    var width = colorPickerCanvas.width;
    var height= colorPickerCanvas.height;
    x = Math.max(0, Math.min(x, width-1));
    y = Math.max(0, Math.min(y, height-1));
    sat = x/(width-1);
    val = 1-(y/(height-1));
    updateCanvas();
    updatePreview();
    syncRgbFields();
  }

  function updatePreview(){
    if(!colorPreview) return;
    var rgb = hsvToRgb(hue, sat, val);
    colorPreview.style.backgroundColor = "rgb("+rgb[0]+","+rgb[1]+","+rgb[2]+")";
  }

  function syncRgbFields(){
    if(!rInput || !gInput || !bInput) return;
    var rgb = hsvToRgb(hue, sat, val);
    rInput.value = rgb[0];
    gInput.value = rgb[1];
    bInput.value = rgb[2];
  }

  function initColorPicker(){
    colorPickerCanvas = document.getElementById('colorPickerCanvas');
    hueRange = document.getElementById('hueRange');
    colorPickerCtx = colorPickerCanvas.getContext('2d');
    colorPreview = document.getElementById('customColorPreview');
    rInput = document.getElementById('custom_color_r_modal_input');
    gInput = document.getElementById('custom_color_g_modal_input');
    bInput = document.getElementById('custom_color_b_modal_input');
    
    // Set default values based on current selection or defaults
    var defaultR = 140, defaultG = 170, defaultB = 134;
    
    // Try to get current color from the hidden input if available
    const hiddenColorInput = document.getElementById('edit_selected_color');
    if (hiddenColorInput && hiddenColorInput.value && hiddenColorInput.value !== 'custom' && hiddenColorInput.value.includes(',')) {
        const [r,g,b] = hiddenColorInput.value.split(',').map(s => parseInt(s.trim(), 10));
        if (!isNaN(r) && !isNaN(g) && !isNaN(b)) {
            defaultR = r; defaultG = g; defaultB = b;
        }
    }
    
    var hsv = rgbToHsv(defaultR, defaultG, defaultB);
    hue = hsv[0]; sat = hsv[1]; val = hsv[2];
    hueRange.value = Math.round(hue).toString();
    rInput.value = defaultR.toString();
    gInput.value = defaultG.toString();
    bInput.value = defaultB.toString();
    
    updateCanvas();
    updatePreview();
    
    // Canvas event listeners
    colorPickerCanvas.onmousedown = function(e){ isMouseDown = true; pickColor(e); };
    colorPickerCanvas.onmousemove = function(e){ if(isMouseDown) pickColor(e); };
    colorPickerCanvas.onmouseup = function(e){ isMouseDown = false; };
    colorPickerCanvas.onmouseleave = function(e){ isMouseDown = false; };
    
    // Hue slider listener
    hueRange.oninput = function(){
      hue = parseInt(this.value, 10);
      updateCanvas();
      updatePreview();
      syncRgbFields();
    };
    
    // RGB input listeners
    [rInput, gInput, bInput].forEach(function(inp){
      inp.addEventListener('input', function(){
        var rv = parseInt(rInput.value,10) || 0;
        var gv = parseInt(gInput.value,10) || 0;
        var bv = parseInt(bInput.value,10) || 0;
        var resultHsv = rgbToHsv(rv, gv, bv);
        hue = resultHsv[0]; sat = resultHsv[1]; val = resultHsv[2];
        hueRange.value = Math.round(hue).toString();
        updateCanvas();
        updatePreview();
      });
    });
  }

  // --- Core Dialog Functions ---

  window.filterComponents = function(inputElement) {
    const query = inputElement.value.toLowerCase().trim();
    const plantItems = document.querySelectorAll('#plant-list .plant-item');
    if (plantItems) {
        plantItems.forEach(item => {
        const textElement = item.querySelector('.plant-item-text');
        if (textElement) {
            const text = textElement.textContent.toLowerCase();
            item.style.display = text.includes(query) ? 'flex' : 'none';
        }
        });
    }
  };

  function renderPlantList() {
    const plantListDiv = document.getElementById('plant-list');
    if (!plantListDiv) {
      console.error('PLANTCOLLECTION JS: #plant-list div not found!'); return;
    }
    plantListDiv.innerHTML = '';
    if (Object.keys(attributesMap).length === 0) {
      plantListDiv.innerHTML = '<div class="plant-item-empty">No plants found in the collection.</div>';
      return;
    }
    const fragment = document.createDocumentFragment();
    const sortedPlantIds = Object.keys(attributesMap).sort((a, b) => {
        const nameA = (attributesMap[a].botanical_name || a).toLowerCase();
        const nameB = (attributesMap[b].botanical_name || b).toLowerCase();
        if (nameA < nameB) return -1;
        if (nameA > nameB) return 1;
        return 0;
    });

    sortedPlantIds.forEach(componentId => {
      const plantData = attributesMap[componentId];
      const itemDiv = document.createElement('div');
      itemDiv.className = 'plant-item';
      itemDiv.setAttribute('data-component-id', componentId);
      itemDiv.id = `plant-item-${componentId}`;
      itemDiv.setAttribute('role', 'option');
      itemDiv.setAttribute('tabindex', '-1');

      const textSpan = document.createElement('span');
      textSpan.className = 'plant-item-text';
      textSpan.textContent = plantData.botanical_name || componentId;
      itemDiv.appendChild(textSpan);

      itemDiv.onclick = function() {
        document.querySelectorAll('#plant-list .plant-item.selected').forEach(el => {
          el.classList.remove('selected');
          el.removeAttribute('aria-selected');
        });
        itemDiv.classList.add('selected');
        itemDiv.setAttribute('aria-selected', 'true');
        itemDiv.focus();
        window.showComponentAttributes(componentId);
      };
      itemDiv.onkeydown = function(event) {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault();
          itemDiv.click();
        }
      };
      fragment.appendChild(itemDiv);
    });
    plantListDiv.appendChild(fragment);
  }

  function fetchFullPlantDetails(componentId) {
    console.log('PLANTCOLLECTION JS: Requesting full details for ID:', componentId);
    const detailsContainer = document.getElementById('plant-details');
    if (detailsContainer) {
        detailsContainer.innerHTML = '<div class="placeholder-message" role="status">Loading details...</div>';
    }
    if (window.sketchup && typeof window.sketchup.fetchPlantDetailsCallback === 'function') {
        const plantEntry = attributesMap[componentId];
        if (plantEntry && plantEntry.file_path) {
            window.sketchup.fetchPlantDetailsCallback(plantEntry.file_path, componentId);
        } else {
            console.error('PLANTCOLLECTION JS: Cannot fetch details. File path missing for componentId:', componentId);
            if (detailsContainer) {
                detailsContainer.innerHTML = '<div class="placeholder-message" role="alert">Error: Could not find file path to load details.</div>';
            }
        }
    } else {
        console.error('PLANTCOLLECTION JS: SketchUp callback "fetchPlantDetailsCallback" not found!');
        if (detailsContainer) {
            detailsContainer.innerHTML = '<div class="placeholder-message" role="alert">Error: Cannot communicate with SketchUp to load details.</div>';
        }
    }
  }

  window.receiveFullPlantDetails = function(componentId, fullAttributes) {
    console.log('PLANTCOLLECTION JS: Received full details for ID:', componentId);
    if (attributesMap[componentId] && fullAttributes) {
        if (fullAttributes.load_error) {
            console.error("PLANTCOLLECTION JS: Ruby reported an error loading details for", componentId, fullAttributes.message || '');
            const detailsContainer = document.getElementById('plant-details');
            if (detailsContainer) {
                detailsContainer.innerHTML = `<div class="placeholder-message" role="alert">Error loading details for ${escapeHtml(attributesMap[componentId].botanical_name || componentId)}.</div>`;
            }
            attributesMap[componentId].dynamic_attributes = { _placeholder: true, _details_loaded: false, _load_error: true };
            return;
        }
        attributesMap[componentId].dynamic_attributes = fullAttributes;
        attributesMap[componentId].dynamic_attributes._details_loaded = true;
        if (fullAttributes.botanical_name && attributesMap[componentId].botanical_name !== fullAttributes.botanical_name) {
            attributesMap[componentId].botanical_name = fullAttributes.botanical_name;
            const listItemText = document.querySelector(`#plant-item-${componentId} .plant-item-text`);
            if (listItemText) { listItemText.textContent = fullAttributes.botanical_name; }
        }
        if (window.currentComponentId === componentId) {
            renderPlantDetailsView(componentId);
        }
    } else {
        console.error('PLANTCOLLECTION JS: Component ID not found in map or no attributes received for ID:', componentId);
    }
  };

  function renderPlantDetailsView(componentId) {
    const detailsContainer = document.getElementById('plant-details');
    if (!detailsContainer) { console.error('PLANTCOLLECTION JS: #plant-details container not found!'); return; }
    const plant = attributesMap[componentId];
    if (!plant || !plant.dynamic_attributes || !plant.dynamic_attributes._details_loaded) {
      console.warn('PLANTCOLLECTION JS: Full plant details not loaded for ID (renderPlantDetailsView):', componentId);
      detailsContainer.innerHTML = '<div class="placeholder-message" role="status">Plant details are not fully loaded.</div>';
      if (plant && (!plant.dynamic_attributes || !plant.dynamic_attributes._details_loaded) && !(plant.dynamic_attributes && plant.dynamic_attributes._load_error)) {
        fetchFullPlantDetails(componentId);
      }
      return;
    }
    if (plant.dynamic_attributes._load_error) {
         detailsContainer.innerHTML = `<div class="placeholder-message" role="alert">Error loading details for ${escapeHtml(plant.botanical_name || componentId)}.</div>`;
        return;
    }
    detailsContainer.innerHTML = '';
    const fragment = document.createDocumentFragment();
    const header = document.createElement('h2');
    header.className = 'plant-header';
    header.id = 'plantDetailsHeader';
    header.textContent = plant.botanical_name || componentId;
    fragment.appendChild(header);

    function createAttributeRow(label, value, isHtmlValue = false) {
      const rowDiv = document.createElement('div');
      rowDiv.className = 'attribute-row';
      const labelSpan = document.createElement('span');
      labelSpan.className = 'attribute-label';
      labelSpan.textContent = label + ':';
      rowDiv.appendChild(labelSpan);
      const valueSpan = document.createElement('span');
      valueSpan.className = 'attribute-value';
      if (isHtmlValue) {
        valueSpan.innerHTML = value;
      } else {
        let displayValue = (value === undefined || value === null || String(value).trim() === "") ?
                           "Edit plant to add." : String(value);
        const attributeKey = Object.keys(friendlyLabels).find(key => friendlyLabels[key] === label) || label.toLowerCase().replace(/\s+/g, '_').replace('(mm)','').replace(':','');
        if (['description', 'plant_care', 'notes'].includes(attributeKey)) {
            const pre = document.createElement('pre');
            pre.textContent = displayValue;
            valueSpan.appendChild(pre);
        } else {
            valueSpan.textContent = displayValue;
        }
      }
      rowDiv.appendChild(valueSpan);
      return rowDiv;
    }

    let row;
    const da = plant.dynamic_attributes;
    const attributeOrder = [
        'common_name', 'category', 'foliage', 'colour',
        'plant_height', 'full_spread', 'flowering_period', 'hardiness', 'exposure', 'aspect', 'light_levels',
        'soil_texture', 'soil_pH', 'soil_moisture',
        'description', 'plant_care', 'notes'
    ];
    attributeOrder.forEach(key => {
        const displayLabel = (friendlyLabels && friendlyLabels[key]) ? friendlyLabels[key] : key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
        if (key === 'colour') {
          const colorValue = da.colour || da.color;
          const cssColorForDetails = colorValToCss(colorValue);
          const colorSwatchHtml = `<span class="color-circle" style="background-color: ${cssColorForDetails};" aria-label="Color swatch for ${escapeHtml(colorValue || 'default color')}"></span>`;
          row = createAttributeRow(displayLabel, colorSwatchHtml, true);
        } else {
          row = createAttributeRow(displayLabel, da[key]);
        }
        if (row) fragment.appendChild(row);
    });

    const buttonContainer = document.createElement('div');
    buttonContainer.className = 'view-button-container';
    const editButton = document.createElement('button');
    editButton.textContent = 'Edit';
    editButton.setAttribute('aria-label', `Edit attributes for ${escapeHtml(plant.botanical_name || componentId)}`);
    editButton.onclick = function() { switchToEditMode(componentId); };
    buttonContainer.appendChild(editButton);
    const deleteButton = document.createElement('button');
    deleteButton.textContent = 'Delete';
    deleteButton.className = 'danger';
    deleteButton.setAttribute('aria-label', `Delete plant ${escapeHtml(plant.botanical_name || componentId)}`);
    
    // UPDATED: Replace confirm() with showDeleteConfirmation()
    deleteButton.onclick = function() {
        const plantName = plant.botanical_name || componentId;
        showDeleteConfirmation(plantName, function() {
            // This callback runs when user confirms deletion
            if (window.sketchup && typeof window.sketchup.deletePlantFile === 'function') {
                if (plant && plant.file_path) {
                    const dataToSendForDelete = { componentId: componentId, filePath: plant.file_path };
                    window.sketchup.deletePlantFile(JSON.stringify(dataToSendForDelete));
                } else { 
                    alert('Error: Could not find file path for deletion.'); 
                }
            } else { 
                alert('Delete function not available.'); 
            }
        });
    };
    
    buttonContainer.appendChild(deleteButton);
    const closeButton = document.createElement('button');
    closeButton.textContent = 'Close';
    closeButton.className = 'secondary';
    closeButton.setAttribute('aria-label', 'Close Plant Collection dialog');
    closeButton.onclick = function() {
      if (window.sketchup && typeof window.sketchup.closePlantCollectionDialog === 'function') {
        window.sketchup.closePlantCollectionDialog();
      }
    };
    buttonContainer.appendChild(closeButton);
    fragment.appendChild(buttonContainer);
    detailsContainer.appendChild(fragment);
  }

  window.showComponentAttributes = function(componentId) {
    window.currentComponentId = componentId;
    const plant = attributesMap[componentId];
    if (!plant) {
      console.error('PLANTCOLLECTION JS: Plant data not found for ID:', componentId);
      const detailsContainer = document.getElementById('plant-details');
      if (detailsContainer) { detailsContainer.innerHTML = '<div class="placeholder-message">Plant details not found.</div>';}
      return;
    }
    if (!plant.dynamic_attributes || !plant.dynamic_attributes._details_loaded) {
        if (plant.dynamic_attributes && plant.dynamic_attributes._load_error) {
            const detailsContainer = document.getElementById('plant-details');
            if (detailsContainer) { detailsContainer.innerHTML = `<div class="placeholder-message" role="alert">Error loading details for ${escapeHtml(plant.botanical_name || componentId)}.</div>`;}
        } else { fetchFullPlantDetails(componentId); }
    } else { renderPlantDetailsView(componentId); }
  };

  window.switchToEditMode = function(componentId) {
    console.log('PLANTCOLLECTION JS: switchToEditMode for ID:', componentId);
    const detailsContainer = document.getElementById('plant-details');
    if (!detailsContainer) { console.error("PLANTCOLLECTION JS: #plant-details not found for edit mode."); return; }
    const plant = attributesMap[componentId];
    if (!plant || !plant.dynamic_attributes || !plant.dynamic_attributes._details_loaded) {
      detailsContainer.innerHTML = '<div class="placeholder-message" role="status">Cannot edit. Details not fully loaded.</div>';
      if (plant && (!plant.dynamic_attributes || !plant.dynamic_attributes._details_loaded) && !(plant.dynamic_attributes && plant.dynamic_attributes._load_error)) {
        fetchFullPlantDetails(componentId);
      }
      return;
    }
    if (plant.dynamic_attributes._load_error) {
        detailsContainer.innerHTML = `<div class="placeholder-message" role="alert">Cannot edit due to previous error loading details for ${escapeHtml(plant.botanical_name || componentId)}.</div>`;
        return;
    }
    originalPlantAttributes = JSON.parse(JSON.stringify(plant.dynamic_attributes || {}));
    delete originalPlantAttributes._details_loaded; delete originalPlantAttributes._placeholder; delete originalPlantAttributes._load_error;
    detailsContainer.innerHTML = '';
    const header = document.createElement('h2');
    header.className = 'plant-header'; header.id = 'editPlantHeader';
    header.textContent = `Editing: ${(plant.botanical_name || componentId)}`;
    detailsContainer.appendChild(header);
    const formTable = document.createElement('table');
    formTable.id = 'editAttributesTable'; formTable.setAttribute('aria-labelledby', 'editPlantHeader');
    const tbody = formTable.createTBody();
    const da = plant.dynamic_attributes;
    const editAttributeOrder = [
      'common_name', 'category', 'foliage', 'colour',
      'plant_height', 'full_spread', 'flowering_period', 'hardiness', 'exposure', 'aspect', 'light_levels',
      'soil_texture', 'soil_pH', 'soil_moisture',
      'description', 'plant_care', 'notes'
    ];
    editAttributeOrder.forEach(key => {
      const row = tbody.insertRow();
      const labelCell = row.insertCell();
      const inputCell = row.insertCell();
      const labelText = (friendlyLabels && friendlyLabels[key]) ? friendlyLabels[key] : key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
      const inputId = `edit_${key}`;
      labelCell.innerHTML = `<label for="${inputId}">${labelText}:</label>`;
     
      let currentValue = da[key] !== undefined ? String(da[key]) : "";
      if (key === 'colour' && currentValue === "" && da['color'] !== undefined) { currentValue = String(da['color']);}

      if (selectOptions && selectOptions[key]) {
        const select = document.createElement('select');
        select.id = inputId; select.setAttribute('aria-label', labelText);
        selectOptions[key].forEach(optVal => {
          const option = document.createElement('option');
          option.value = optVal; option.textContent = optVal === "" ? "Choose..." : optVal;
          if (optVal === currentValue) { option.selected = true; }
          select.appendChild(option);
        });
        inputCell.appendChild(select);
      } else if (key === 'colour') {
        const hiddenColorInput = document.createElement('input'); hiddenColorInput.type = 'hidden'; hiddenColorInput.id = 'edit_selected_color'; hiddenColorInput.value = currentValue;
        inputCell.appendChild(hiddenColorInput);
        const swatchesContainer = document.createElement('div'); swatchesContainer.setAttribute('role', 'radiogroup'); swatchesContainer.setAttribute('aria-label', 'Symbol color options');
        swatchesContainer.style.display = 'flex'; swatchesContainer.style.flexWrap = 'wrap'; swatchesContainer.style.gap = '5px';
        const predefinedSwatches = [
         "63,84,67", "141,156,117", "152,171,155", "189,202,193", "86,73,118",
         "99,110,178", "181,191,227", "197,57,51", "136,65,67", "250,224,157",
         "232,215,83", "227,147,66", "244,226,232", "242,203,203", "248,249,247"
        ];
        predefinedSwatches.forEach(rgbString => {
          const swatch = document.createElement('div'); swatch.className = 'color-swatch'; swatch.style.backgroundColor = `rgb(${rgbString})`; swatch.dataset.rgb = rgbString;
          swatch.setAttribute('role', 'radio'); swatch.setAttribute('aria-label', `Select color ${rgbString}`); swatch.setAttribute('tabindex', '0');
          if (rgbString === currentValue) { swatch.classList.add('selected'); swatch.setAttribute('aria-checked', 'true'); } else { swatch.setAttribute('aria-checked', 'false');}
          swatch.onclick = function() {
            document.querySelectorAll('#editAttributesTable .color-swatch').forEach(s => { s.classList.remove('selected'); s.setAttribute('aria-checked', 'false'); });
            this.classList.add('selected'); this.setAttribute('aria-checked', 'true');
            hiddenColorInput.value = this.dataset.rgb;
          };
          swatch.onkeydown = function(e) { if(e.key === 'Enter' || e.key === ' ') { e.preventDefault(); this.click(); }};
          swatchesContainer.appendChild(swatch);
        });
        const customSwatch = document.createElement('div'); customSwatch.className = 'color-swatch custom'; customSwatch.setAttribute('role', 'button');
        customSwatch.setAttribute('aria-label', 'Select custom color'); customSwatch.setAttribute('tabindex', '0');
        if (!predefinedSwatches.includes(currentValue) && currentValue.includes(',')) {
           customSwatch.style.backgroundColor = `rgb(${currentValue})`; customSwatch.classList.add('selected');
        } else if (currentValue.toLowerCase() === "custom" && !predefinedSwatches.includes(currentValue)){ customSwatch.classList.add('selected');}
        customSwatch.onclick = function() { window.openCustomColorModal(); };
        customSwatch.onkeydown = function(e) { if(e.key === 'Enter' || e.key === ' ') { e.preventDefault(); this.click(); }};
        swatchesContainer.appendChild(customSwatch); inputCell.appendChild(swatchesContainer);
        const opacityDiv = document.createElement('div'); opacityDiv.style.marginTop = '8px';
        const opacityCheckbox = document.createElement('input'); opacityCheckbox.type = 'checkbox'; opacityCheckbox.id = 'edit_reduce_opacity';
        opacityCheckbox.checked = String(da.reduce_opacity).toLowerCase() === 'true';
        const opacityLabelEl = document.createElement('label'); opacityLabelEl.htmlFor = 'edit_reduce_opacity';
        opacityLabelEl.textContent = (friendlyLabels && friendlyLabels.reduce_opacity) ? friendlyLabels.reduce_opacity : ' Add Transparency?';
        opacityLabelEl.style.marginLeft = '5px';
        opacityDiv.appendChild(opacityCheckbox); opacityDiv.appendChild(opacityLabelEl); inputCell.appendChild(opacityDiv);
      } else if (['description', 'plant_care', 'notes'].includes(key)) {
        const textarea = document.createElement('textarea'); textarea.id = inputId; textarea.rows = 4; textarea.value = currentValue; textarea.setAttribute('aria-label', labelText);
        inputCell.appendChild(textarea);
      } else {
        const input = document.createElement('input');
        input.type = (['plant_height', 'full_spread'].includes(key)) ? 'number' : 'text';
        input.id = inputId; input.value = currentValue; input.setAttribute('aria-label', labelText);
        if (input.type === 'number') { input.step = 'any'; }
        inputCell.appendChild(input);
      }
    });
    detailsContainer.appendChild(formTable);
    const editButtonContainer = document.createElement('div'); editButtonContainer.className = 'edit-button-container';
    const saveButton = document.createElement('button'); saveButton.textContent = 'Save Changes'; saveButton.setAttribute('aria-label', 'Save all changes made to this plant');
    saveButton.onclick = function() { saveEditedAttributes(componentId); }; editButtonContainer.appendChild(saveButton);
    const cancelButton = document.createElement('button'); cancelButton.textContent = 'Cancel'; cancelButton.className = 'secondary'; cancelButton.setAttribute('aria-label', 'Cancel editing and discard any changes');
    cancelButton.onclick = function() { window.showComponentAttributes(componentId); }; editButtonContainer.appendChild(cancelButton);
    detailsContainer.appendChild(editButtonContainer);
  };

  function saveEditedAttributes(componentId) {
    const updates = {}; let hasChanges = false;
    if (Object.keys(originalPlantAttributes).length === 0 && attributesMap[componentId]?.dynamic_attributes?._details_loaded) {
        originalPlantAttributes = JSON.parse(JSON.stringify(attributesMap[componentId].dynamic_attributes));
        delete originalPlantAttributes._details_loaded; delete originalPlantAttributes._placeholder; delete originalPlantAttributes._load_error;
    } else if (Object.keys(originalPlantAttributes).length === 0) {
        showSaveError('Cannot determine original attributes for comparison. Please reload.'); return;
    }
    const editAttributeOrder = [
      'common_name', 'category', 'foliage', 'plant_height', 'full_spread',
      'flowering_period', 'hardiness', 'exposure', 'aspect', 'light_levels',
      'soil_texture', 'soil_pH', 'soil_moisture', 'description', 'plant_care', 'notes'
    ];
    editAttributeOrder.forEach(key => {
        const inputElement = document.getElementById(`edit_${key}`);
        if (inputElement) {
            let newValue = inputElement.value;
            if (typeof newValue === 'string') { newValue = newValue.trim(); }
            updates[key] = newValue;
            const originalValueString = (originalPlantAttributes[key] !== undefined && originalPlantAttributes[key] !== null) ? String(originalPlantAttributes[key]) : "";
            const comparableOriginalValue = (typeof originalValueString === 'string') ? originalValueString.trim() : originalValueString;
            if (String(newValue) !== comparableOriginalValue) { hasChanges = true; }
        }
    });
    const selectedColorInput = document.getElementById('edit_selected_color');
    if (selectedColorInput) {
        const newColorValue = selectedColorInput.value.trim();
        updates.colour = newColorValue;
        const originalColor = (originalPlantAttributes.colour || originalPlantAttributes.color || "").trim();
        if (newColorValue !== originalColor) { hasChanges = true; }
    }
    const reduceOpacityCheckbox = document.getElementById('edit_reduce_opacity');
    if (reduceOpacityCheckbox) {
        const newOpacityValue = reduceOpacityCheckbox.checked ? 'true' : 'false';
        updates.reduce_opacity = newOpacityValue;
        const originalOpacity = (String(originalPlantAttributes.reduce_opacity).toLowerCase() === 'true' ? 'true' : 'false');
        if (newOpacityValue !== originalOpacity) { hasChanges = true; }
    }
   
    if (hasChanges) {
        if (window.sketchup && typeof window.sketchup.saveUpdatedAttributes === 'function') {
            const plantData = attributesMap[componentId];
            if (plantData && plantData.file_path) {
                const dataToSend = { componentId: componentId, filePath: plantData.file_path, updates: updates };
                console.log("PLANTCOLLECTION JS: Sending attribute updates to Ruby:", JSON.stringify(dataToSend));
                window.sketchup.saveUpdatedAttributes(JSON.stringify(dataToSend));
            } else { showSaveError('Critical error: Original file path for plant is missing.'); }
        } else { showSaveError('Save function (sketchup.saveUpdatedAttributes) not available.'); }
    } else {
        console.log("PLANTCOLLECTION JS: No changes detected to save.");
        if (window.sketchup && typeof window.sketchup.noChangesMade === 'function') {
            window.sketchup.noChangesMade(componentId);
        } else { window.showComponentAttributes(componentId); }
    }
  }

  // --- Enhanced Custom Color Modal Functions ---

  window.openCustomColorModal = function() {
    const modal = document.getElementById('customColorModal');
    if (modal) modal.style.display = 'flex';
    initColorPicker();
    const firstInput = document.getElementById('custom_color_r_modal_input');
    if (firstInput) {
        firstInput.focus();
    }
  };
  
  window.closeCustomColorModal = function() {
    const modal = document.getElementById('customColorModal');
    if (modal) modal.style.display = 'none';
    const customSwatchButton = document.querySelector('#editAttributesTable .color-swatch.custom');
    if (customSwatchButton) {
        customSwatchButton.focus();
    }
  };
  
  window.setCustomColorFromModal = function() {
    const rVal = document.getElementById('custom_color_r_modal_input').value;
    const gVal = document.getElementById('custom_color_g_modal_input').value;
    const bVal = document.getElementById('custom_color_b_modal_input').value;
    if (rVal === '' || gVal === '' || bVal === '') { alert("Please fill in R, G, and B fields (0-255)."); return; }
    const rNum = parseInt(rVal, 10), gNum = parseInt(gVal, 10), bNum = parseInt(bVal, 10);
    if (isNaN(rNum) || isNaN(gNum) || isNaN(bNum) || rNum < 0 || rNum > 255 || gNum < 0 || gNum > 255 || bNum < 0 || bNum > 255) {
        alert("Please enter valid numbers between 0 and 255 for R, G, and B."); return;
    }
    const newRGB = `${rNum},${gNum},${bNum}`;
    const hiddenField = document.getElementById('edit_selected_color');
    if (hiddenField) { hiddenField.value = newRGB; }
    const customSwatch = document.querySelector('#editAttributesTable .color-swatch.custom');
    if (customSwatch) {
      customSwatch.style.backgroundColor = `rgb(${newRGB})`;
      document.querySelectorAll('#editAttributesTable .color-swatch').forEach(s => {s.classList.remove('selected'); s.setAttribute('aria-checked', 'false');});
      customSwatch.classList.add('selected'); customSwatch.setAttribute('aria-checked', 'true');
    }
    closeCustomColorModal();
  };

  // DELETE MODAL FUNCTIONS - NEW ADDITIONS
  window.showDeleteConfirmation = function(plantName, onConfirm) {
    const modal = document.getElementById('deleteModal');
    const message = document.getElementById('deleteModalMessage');
    const confirmBtn = document.getElementById('confirmDeleteBtn');
    const cancelBtn = document.getElementById('cancelDeleteBtn');
    
    if (!modal || !message || !confirmBtn || !cancelBtn) {
      console.error('PLANTCOLLECTION JS: Delete modal elements not found');
      return;
    }
    
    // Set the message
    message.innerHTML = `Are you sure you want to delete "<strong>${escapeHtml(plantName)}</strong>"?<br>This cannot be undone.`;
    
    // Show modal
    modal.style.display = 'flex';
    
    // Handle confirm
    confirmBtn.onclick = function() {
      hideDeleteConfirmation();
      if (onConfirm) onConfirm();
    };
    
    // Handle cancel
    cancelBtn.onclick = hideDeleteConfirmation;
    
    // Handle click outside modal
    modal.onclick = function(e) {
      if (e.target === modal) {
        hideDeleteConfirmation();
      }
    };
    
    // Handle ESC key
    document.addEventListener('keydown', handleDeleteModalEscape);
    
    // Focus the cancel button by default for accessibility
    cancelBtn.focus();
  };

  window.hideDeleteConfirmation = function() {
    const modal = document.getElementById('deleteModal');
    if (modal) {
      modal.style.display = 'none';
    }
    document.removeEventListener('keydown', handleDeleteModalEscape);
    
    // Clean up event listeners
    const confirmBtn = document.getElementById('confirmDeleteBtn');
    const cancelBtn = document.getElementById('cancelDeleteBtn');
    if (confirmBtn) confirmBtn.onclick = null;
    if (cancelBtn) cancelBtn.onclick = null;
    if (modal) modal.onclick = null;
  };

  function handleDeleteModalEscape(e) {
    if (e.key === 'Escape') {
      hideDeleteConfirmation();
    }
  }

  window.showSaveSuccess = function() { };
  window.showSaveError = function(errorMessage) {
    console.error("PLANTCOLLECTION JS Save Error:", errorMessage);
  };

  window.updateAttributesMapAndRefreshView = function(componentId, fullyUpdatedAttributes) {
    console.log('PLANTCOLLECTION JS: updateAttributesMapAndRefreshView for ID:', componentId);
    if (attributesMap.hasOwnProperty(componentId) && fullyUpdatedAttributes) {
        attributesMap[componentId].dynamic_attributes = fullyUpdatedAttributes;
        attributesMap[componentId].dynamic_attributes._details_loaded = true;
        if (fullyUpdatedAttributes.botanical_name && attributesMap[componentId].botanical_name !== fullyUpdatedAttributes.botanical_name) {
            attributesMap[componentId].botanical_name = fullyUpdatedAttributes.botanical_name;
        }
        renderPlantList();
        if (window.currentComponentId === componentId) {
            const selectedItem = document.getElementById(`plant-item-${componentId}`);
            if (selectedItem) {
                document.querySelectorAll('#plant-list .plant-item.selected').forEach(el => {el.classList.remove('selected'); el.removeAttribute('aria-selected');});
                selectedItem.classList.add('selected'); selectedItem.setAttribute('aria-selected', 'true');
                selectedItem.focus();
            }
            renderPlantDetailsView(componentId);
        }
    }
  };

  window.removeItemFromCollection = function(componentId) {
    console.log("PLANTCOLLECTION JS: removeItemFromCollection for ID:", componentId);
    if (attributesMap.hasOwnProperty(componentId)) {
        delete attributesMap[componentId];
        renderPlantList();
        const detailsContainer = document.getElementById('plant-details');
        if (window.currentComponentId === componentId) {
            if (detailsContainer) {
                detailsContainer.innerHTML = '<div class="placeholder-message">Plant has been deleted. Select another plant from the list.</div>';
            }
            window.currentComponentId = null;
        } else if (Object.keys(attributesMap).length === 0 && detailsContainer) {
             detailsContainer.innerHTML = '<div class="placeholder-message">No plants left in the collection.</div>';
        }
    }
  };

  window.clearPlantList = function() {
    console.log('PLANTCOLLECTION JS: clearPlantList called.');
    const plantListDiv = document.getElementById('plant-list');
    if (plantListDiv) { plantListDiv.innerHTML = ''; }
    const detailsContainer = document.getElementById('plant-details');
    if (detailsContainer) {
      detailsContainer.innerHTML = '<div class="placeholder-message">Refreshing plant list...</div>';
    }
    attributesMap = {};
    window.currentComponentId = null;
  };

  window.initializeAttributes = function(data, labels, options) {
    console.log('PLANTCOLLECTION JS: initializeAttributes. Items:', data ? Object.keys(data).length : 'null');
    attributesMap = data || {}; friendlyLabels = labels || {}; selectOptions = options || {};
    renderPlantList();
    const detailsContainer = document.getElementById('plant-details');
    if (detailsContainer) {
        detailsContainer.innerHTML = `<div class="placeholder-message">${Object.keys(attributesMap).length > 0 ? 'Select a plant from the list to view its details.' : 'No plants found in your library.'}</div>`;
    }
    window.currentComponentId = null;
  };

  // --- DOMContentLoaded + Improved Keyboard Navigation ---
  document.addEventListener('DOMContentLoaded', function() {
    if (window.sketchup && typeof window.sketchup.js_is_ready === 'function') {
      console.log('PLANTCOLLECTION JS: DOMContentLoaded - Signaling Ruby js_is_ready...');
      window.sketchup.js_is_ready();
    } else {
     console.error('PLANTCOLLECTION JS: DOMContentLoaded - sketchup.js_is_ready callback not found!');
    }
    
    const customColorModalElement = document.getElementById('customColorModal');
    if (customColorModalElement) {
        customColorModalElement.addEventListener('click', function(event) {
            if (event.target === customColorModalElement) { closeCustomColorModal(); }
        });
        customColorModalElement.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') { closeCustomColorModal(); }
        });
    }

    // DELETE MODAL EVENT HANDLING - NEW ADDITION
    const deleteModalElement = document.getElementById('deleteModal');
    if (deleteModalElement) {
        deleteModalElement.addEventListener('click', function(event) {
            if (event.target === deleteModalElement) { 
                hideDeleteConfirmation(); 
            }
        });
        deleteModalElement.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') { 
                hideDeleteConfirmation(); 
            }
        });
    }

    // --- IMPROVED KEYDOWN NAVIGATION LOGIC FOR PLANT LIST (updates selection immediately) ---
    const plantList = document.getElementById('plant-list');
    if (plantList) {
        plantList.addEventListener('keydown', function(event) {
            const currentFocused = document.activeElement;
            let targetItem = null;

            if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
                event.preventDefault();

                if (!currentFocused || !currentFocused.classList.contains('plant-item') || !plantList.contains(currentFocused)) {
                    // If no valid plant item is focused, focus first visible item
                    targetItem = plantList.querySelector('.plant-item:not([style*="display: none"])');
                } else {
                    // Find next/previous visible sibling
                    let sibling = (event.key === 'ArrowDown')
                        ? currentFocused.nextElementSibling
                        : currentFocused.previousElementSibling;
                    while (sibling) {
                        if (
                            sibling.classList.contains('plant-item') &&
                            (!sibling.style.display || sibling.style.display !== 'none')
                        ) {
                            targetItem = sibling;
                            break;
                        }
                        sibling = (event.key === 'ArrowDown')
                            ? sibling.nextElementSibling
                            : sibling.previousElementSibling;
                    }
                }

                if (targetItem) {
                    targetItem.focus();
                    targetItem.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'nearest' });
                    // --- Update selection and detail view on keyboard navigation ---
                    document.querySelectorAll('#plant-list .plant-item.selected').forEach(el => {
                        el.classList.remove('selected');
                        el.removeAttribute('aria-selected');
                    });
                    targetItem.classList.add('selected');
                    targetItem.setAttribute('aria-selected', 'true');
                    window.showComponentAttributes(targetItem.dataset.componentId);
                }
            }
            // Note: Enter/Space are handled per item with onkeydown already
        });
    }
  });

})(); // End of the single, main IIFE
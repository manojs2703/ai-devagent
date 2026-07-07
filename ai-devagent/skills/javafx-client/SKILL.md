---
name: javafx-client
description: Load when working on JavaFX desktop client modules — controllers, FXML views, table views, filters, or forms.
---

# Skill: JavaFX Client Development

## When to Apply This Skill

Load this skill when working on JavaFX desktop client modules — creating or modifying controllers, FXML views, table views, filters, or forms.
**Project override**: Check project memory for project-specific components (GreenLemonFX `FilterExtTableView`, `LoadableControllerIF`, etc.).

---

## Controller Lifecycle (initialize → load → loadDone)

A clean pattern for async data loading separates background work from UI updates:

```java
public class ProductListController {

    private final ObservableList<ProductRow> rows = FXCollections.observableArrayList();

    @FXML private TableView<ProductRow> table;
    @FXML private TableColumn<ProductRow, String> columnName;
    @FXML private TableColumn<ProductRow, String> columnPrice;
    @FXML private Button refreshButton;

    @FXML
    public void initialize() {
        columnName.setCellValueFactory(cell -> cell.getValue().nameProperty());
        columnPrice.setCellValueFactory(cell -> cell.getValue().priceProperty());
        table.setItems(rows);
        loadData();
    }

    private void loadData() {
        refreshButton.setDisable(true);
        Task<List<ProductDto>> task = new Task<>() {
            @Override
            protected List<ProductDto> call() {
                return productService.findAll();   // runs on background thread
            }
        };
        task.setOnSucceeded(e -> {
            rows.setAll(toRows(task.getValue()));  // runs on FX thread
            refreshButton.setDisable(false);
        });
        task.setOnFailed(e -> {
            showError("Failed to load products", task.getException());
            refreshButton.setDisable(false);
        });
        new Thread(task, "product-loader").start();
    }
}
```

---

## Threading Rules

```java
// ✅ Background thread — do slow work here
Task<List<ProductDto>> task = new Task<>() {
    @Override
    protected List<ProductDto> call() {
        return productService.findAll();  // remote call — OK on background thread
    }
};

// ✅ FX thread — update UI here
task.setOnSucceeded(e -> rows.setAll(toRows(task.getValue())));

// ❌ Never call slow operations on the FX thread
Platform.runLater(() -> {
    rows.setAll(productService.findAll()); // BAD — blocks UI
});

// ❌ Never update UI from a background thread
new Thread(() -> {
    var data = productService.findAll();
    table.setItems(data);  // BAD — not on FX thread
}).start();
```

---

## TableView Row Model (JavaFX Properties)

```java
public class ProductRow {

    private final LongProperty id;
    private final StringProperty name;
    private final StringProperty price;

    public ProductRow(ProductDto dto) {
        this.id    = new SimpleLongProperty(dto.id());
        this.name  = new SimpleStringProperty(dto.name());
        this.price = new SimpleStringProperty(dto.price().setScale(2).toPlainString());
    }

    public LongProperty idProperty()     { return id; }
    public StringProperty nameProperty() { return name; }
    public StringProperty priceProperty(){ return price; }

    public Long getId()     { return id.get(); }
    public String getName() { return name.get(); }
}
```

---

## FXML Best Practices

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?import javafx.scene.layout.BorderPane?>
<?import javafx.scene.control.TableView?>
<?import javafx.scene.control.TableColumn?>
<?import javafx.scene.control.Button?>

<BorderPane xmlns:fx="http://javafx.com/fxml"
            fx:controller="com.example.ProductListController">
    <top>
        <!-- ✅ Use resource bundle keys (%key) for i18n -->
        <Button fx:id="refreshButton" text="%button.refresh" onAction="#loadData"/>
    </top>
    <center>
        <TableView fx:id="table">
            <columns>
                <!-- ✅ fx:id must exactly match @FXML field name -->
                <TableColumn fx:id="columnName"  text="%column.name"/>
                <TableColumn fx:id="columnPrice" text="%column.price"/>
            </columns>
        </TableView>
    </center>
</BorderPane>
```

---

## Input Validation

```java
// ✅ Validate before service call — show errors in UI, don't throw
@FXML
void onSave() {
    String name  = nameField.getText();
    String price = priceField.getText();

    List<String> errors = new ArrayList<>();
    if (name == null || name.isBlank())  errors.add("Name is required");
    if (price == null || price.isBlank()) errors.add("Price is required");
    else {
        try { new BigDecimal(price); }
        catch (NumberFormatException e) { errors.add("Price must be a valid number"); }
    }

    if (!errors.isEmpty()) {
        showValidationErrors(errors);
        return;
    }

    saveProduct(name, new BigDecimal(price));
}
```

---

## Common Patterns

```java
// ✅ Empty state placeholder
table.setPlaceholder(new Label("No items found"));

// ✅ Selection listener
table.getSelectionModel().selectedItemProperty()
    .addListener((obs, old, selected) -> editButton.setDisable(selected == null));

// ✅ Confirm dialog before destructive action
@FXML
void onDelete() {
    var selected = table.getSelectionModel().getSelectedItem();
    if (selected == null) return;

    var confirm = new Alert(Alert.AlertType.CONFIRMATION,
        "Delete '" + selected.getName() + "'?",
        ButtonType.YES, ButtonType.NO);
    confirm.showAndWait()
        .filter(bt -> bt == ButtonType.YES)
        .ifPresent(bt -> deleteItem(selected.getId()));
}
```

---

## I18n in Controllers

```java
@Override
public void initialize(URL location, ResourceBundle resources) {
    this.resources = resources;
    // Use resources.getString() for i18n labels
    // Resource bundle loaded automatically from FXML declaration
}

// ✅ Access i18n text
String title = resources.getString("module.title");

// ✅ In FXML — use % prefix for resource bundle keys
// text="%module.title"
```

